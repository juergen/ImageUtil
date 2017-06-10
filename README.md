ImageUtil
=========

Rename Images in OSX (Swift) experiment.
Now migrated to Swift 3.1

!! use at your own risk !!

This app will: 
- rename images using
 - the date of the image meta data 
 - or the image file creation date
- convert raw images to jpg on the fly

The date can be recalculated
 - new base date (e.g. if your camera had no date configured)
 - offset by +/- hours (e.g. you forgot to set time of your travel destination)

The file name will be postfixed by "_1", "_2" etc. to ensure unique names in case images have the same date/time.
e.g. 2014-01-25_17-04_1.jpg, 2014-01-25_17-04_2.jpg

You can add additinal info (e.g. who made the picture).
e.g. "jb" will result in: 2014-01-25_17-04_1_jb.jpg, 2014-01-25_17-04_2_jb.jpg

You can include the original file name to keep a reference to the original name.
e.g. 2014-01-25_17-04_1_jb(IMG01234).jpg, 2014-01-25_17-04_2_jb(IMG01235).jpg

When exporting from orginals from the Mac Photos app, the life photos are exported as .jpg and .mov.
The .mov files will now also be renamed.

