
import copy
import pathlib
import pickle

import fire
import numpy as np
from skimage import io as imgio

from second.core import box_np_ops
#from second.core.point_cloud.point_cloud_ops import bound_points_jit
from second.data import kitti_track_common as kitti_track
from second.utils.progress_bar import list_bar as prog_bar

def _read_imageset_file(path):
    with open(path, 'r') as f:
        lines = f.readlines()
    return [int(line) for line in lines]

def create_kitti_info_file(data_path,
                           save_path=None,
                           create_trainval=False,
                           relative_path=True):


	print("Creating info file")
	if save_path is None:
		save_path = pathlib.Path(data_path)
	else:
		save_path = pathlib.Path(save_path)


	kitti_infos_test = kitti_track.get_kitti_image_info(
		data_path,
		training=False,
		label_info=False,
		velodyne=True,
		calib=True,
		relative_path=relative_path)
	filename = save_path / 'kitti_infos_test.pkl'
	print(f"Kitti info test file is saved to {filename}")
	with open(filename, 'wb') as f:
		pickle.dump(kitti_infos_test, f)



def _create_reduced_point_cloud(data_path,
                                info_path,
                                save_path=None,
                                back=False):
    with open(info_path, 'rb') as f:
        kitti_infos = pickle.load(f)
    for info in prog_bar(kitti_infos):
        pc_info = info["point_cloud"]
        image_info = info["image"]
        calib = info["calib"]

        v_path = pc_info['velodyne_path']
        v_path = pathlib.Path(data_path) / v_path
        points_v = np.fromfile(
            str(v_path), dtype=np.float32, count=-1).reshape([-1, 4])
        rect = calib['R0_rect']
        P2 = calib['P2']
        Trv2c = calib['Tr_velo_to_cam']
        # first remove z < 0 points
        # keep = points_v[:, -1] > 0
        # points_v = points_v[keep]
        # then remove outside.
        if back:
            points_v[:, 0] = -points_v[:, 0]
        points_v = box_np_ops.remove_outside_points(points_v, rect, Trv2c, P2,
                                                    image_info["image_shape"])

        if save_path is None:
            save_filename = v_path.parent.parent / (v_path.parent.stem + "_reduced") / v_path.name
            # save_filename = str(v_path) + '_reduced'
            if back:
                save_filename += "_back"
        else:
            save_filename = str(pathlib.Path(save_path) / v_path.name)
            if back:
                save_filename += "_back"
        with open(save_filename, 'w') as f:
            points_v.tofile(f)


def create_reduced_point_cloud(data_path,
                               test_info_path=None,
                               save_path=None,
                               with_back=False):
    if test_info_path is None:
        test_info_path = pathlib.Path(data_path) / 'kitti_infos_test.pkl'

    _create_reduced_point_cloud(data_path, test_info_path, save_path)
    if with_back:
        _create_reduced_point_cloud(
            data_path, test_info_path, save_path, back=True)


if __name__ == '__main__':
    fire.Fire()
