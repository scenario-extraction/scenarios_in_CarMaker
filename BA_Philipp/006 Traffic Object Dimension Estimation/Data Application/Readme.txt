In order to run code folders 'dat', 'erg, radar', 'images', 'tensors' have to be filled with the respective
files. The purpose of 'bboxes' is to save already detected bounding boxes in it. This makes sense because 
detecting the bounding boxes takes A LOT of time. Simply save bounding boxes when code is run for the first
time (blocks for saving them might need to be activated: if 0 -> if 1) and load them into Matlab by double
clicking when needed. The option in 'main_application...' to save detected bounding boxes is commented out by
default.   

Folders '1 fps' and '2 fps' are simply copies of 1 // 2 fps data. Copy them into this directory (and replace
current content) to use them.