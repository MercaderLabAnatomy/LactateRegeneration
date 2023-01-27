# LactateRegeneration
ImageJ Macro language script to quantify signal from 2D images

The start the file simply drag it to an open FIJI ImageJ window and run.

The macro requires 2 separate directories to function properly:
- input directory with image files
- output directory, will save:
    - selected regions of interest (ROI)
    - signal quantification, in number of detected pixels in selected ROI
  
Further requirements:
- Images with 2 channels, file type nd2
- no Z-stack
