import fire
import glob
import subprocess
import yaml
from google.protobuf import text_format
from second.protos import pipeline_pb2

#dataset structure
#->dataset_root
#-->image_02
#---->0000.png
#---->0001.png
#---->...
#---->xxxx.png
#-->velodyne
#---->0000.bin
#---->0001.bin
#---->...
#---->xxxx.bin
#-->velodyne_reduced
#-->calib
#---->calib.txt
#-->oxts
#---->calib.txt
#

def kitti_track(dataset_root,export_video=False):


    #subprocess.call(["conda","develop", "./Detectorv1.5/second.pytorch"])


    temp_data_dir = dataset_root+'/temp_data'
    subprocess.call(["mkdir",temp_data_dir])
    edit_detector_config(dataset_root,temp_data_dir,'./Kitti-Detector/second.pytorch/second/configs/car.fhd.config')


    subprocess.call(["mkdir",dataset_root+'velodyne_reduced'])

    cmd = ['python', './Kitti-Detector/second.pytorch/second/create_track_data.py','create_kitti_info_file','--data_path='+dataset_root,'--save_path='+temp_data_dir]
    subprocess.Popen(cmd).wait()


    cmd = ['python', './Kitti-Detector/second.pytorch/second/create_track_data.py','create_reduced_point_cloud','--data_path='+dataset_root,'--test_info_path='+temp_data_dir+'/kitti_infos_test.pkl']
    subprocess.Popen(cmd).wait()


    cmd = ['python', './Kitti-Detector/second.pytorch/second/pytorch/detect.py','detect','--config_path=./Kitti-Detector/second.pytorch/second/configs/car.fhd.config','--model_dir=./Kitti-Detector/second.pytorch/pretrained_models_v1.5/car_fhd','--measure_time=True','--batch_size=1','--result_path='+temp_data_dir]
    subprocess.Popen(cmd).wait()


    edit_tracker_config(dataset_root,temp_data_dir,'./Tracker/mmMOT/experiments/pp_pv_40e_dualadd_subabs_C/config.yaml')
    create_dataset_tracker_info_file(dataset_root,temp_data_dir)


    cmd = ['python', './Tracker/mmMOT/track.py','start','--config_path=./Tracker/mmMOT/experiments/pp_pv_40e_dualadd_subabs_C/config.yaml','--load_path=./Tracker/mmMOT/model/pp_pv_40e_dualadd_subabs_C.pth','--result_path='+dataset_root,'--dataset_root='+dataset_root,'--result_sha=result']
    subprocess.Popen(cmd).wait()


    if export_video:
        subprocess.Popen(['ffmpeg','-framerate','10','-start_number','0','-i',dataset_root+'/image_02/%06d.png','-vcodec','libx264','-y','-an',dataset_root+'/result/video.mp4','-vf',"pad=ceil(iw/2)*2:ceil(ih/2)*2"])

    #subprocess.Popen(['cp',dataset_root+'/calib/calib.txt',dataset_root+'/result/calib.txt']).wait()
   # subprocess.Popen(['cp',dataset_root+'/oxts/oxts.txt',dataset_root+'/oxts/oxts.txt']).wait()


def edit_detector_config(dataset_root,temp_data_dir,config_path):
        config = pipeline_pb2.TrainEvalPipelineConfig()
        with open(config_path, "r") as f:
            proto_str = f.read()
            text_format.Merge(proto_str, config)
        config.eval_input_reader.kitti_info_path = temp_data_dir+"/kitti_infos_test.pkl"
        config.eval_input_reader.kitti_root_path  = dataset_root

        config_text = text_format.MessageToString(config)
        with open(config_path, "w") as f:
            f.write(config_text)

def edit_tracker_config(dataset_root,temp_data_dir,config_path):
	with open(config_path) as f:
		config = yaml.load(f, Loader=yaml.FullLoader)
	config['common']['test_root'] = dataset_root
	config['common']['test_source'] = dataset_root+""
	config['common']['test_link'] = temp_data_dir+"/tracker_id.txt"
	config['common']['test_det'] = temp_data_dir+"/result.pkl"

	with open(config_path, "w") as f:
		yaml.dump(config, f)


def create_dataset_tracker_info_file(dataset_root,destination):
	img_path = dataset_root+'/image_02/'
	image_ids = list(range(len(glob.glob(img_path+'*.png'))))
	with open(destination+"/tracker_id.txt", "w") as text_file:
		for id in image_ids:
			print(f"0000-{id:06d}", file=text_file)
		


if __name__ == '__main__':
    fire.Fire()
