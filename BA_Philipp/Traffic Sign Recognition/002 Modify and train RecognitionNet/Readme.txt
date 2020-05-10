The training set of the original data set was split into a training set and a validation set for the purpose of this work. The train/validation split is 0.8/0.2.

Be careful: This data set contains series of images that were taken right after another. These images must not be separated when splitting the training set.
For example: Image with name "00001_00000_00011" means "traffic sign: 1, image series: 0, image in this series: 11"

For determining how many images to keep in the training set and how many to move to the validation set, I created the script "split_training_set".
This script also creates the folder structure needed. The actual moving of the images has not been automated and has to be done manually.