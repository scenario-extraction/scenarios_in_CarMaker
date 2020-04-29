In order to run "main_application...", folders 'dat', 'erg, radar', 'images', 'tensors' have to be filled with the respective
files. The purpose of 'bboxes' is to save already detected bounding boxes in it. This makes sense because detecting bounding 
boxes takes A LOT of time. 

When detect_bboxes = 1 (in "main_application..."), bounding boxes will be detected and saved (already saved ones will be 
overwritten!) in directory "bboxes" for later use. Later, one can load them into Matlab by double clicking on them.   

The subfolders of '000 Scenarios' contain the whole data needed for respective scenarios. Copy them into this directory (and replace current content) to 
use them.

Text document 'This is...' simply is a helpful marker in order to know which scenario is currently located here