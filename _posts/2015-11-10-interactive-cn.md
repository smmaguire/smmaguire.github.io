---
layout: post
title:  "Quantifying Radioactive *in situ*"
date:   2016-7-20 23:40:20 -0600
categories: quantification
---

Currently I'm working on quantifying radioactive *in situ* hybridization. This a technique where you create radioactive riboprobes which target a particular gene. You can then detect binding of the probe using silver-halide emulsion. I thought I would post my method in case it is useful for somebody else (or myself in the future.) I'm using [FIJI](https://fiji.sc) (ie image J for this). A radioactive *in situ* looks like this (for quantification you should use a much more magnified micrograph, probably at least 40x):

![df]({{smmaguire.github.io}}/assests/darkfield_example.jpg)

To quantify the silver grains I took one photo in brightfield and a corresponding photo in darkfield. The darkfield photo separates the silver grains from the background pretty well. In order to quantify the grains we need to do the following steps:

1. Create a mask of the cells. We only want to count grains that developed over cells.
2. Separate overlapping grains. If grains are overlapping they will be counted as a single object. We want to get as close to the true number as possible.
3. Subtract the cell mask (step 1) from the silver grain image to delete grains that are not over cells.
4. Count whatever grains are leftover.

For step 1 you will need to download the [adaptive thresholding](https://sites.google.com/site/qingzongtseng/adaptivethreshold) algorithm from opencv which has been ported to imageJ (you could also do this step in opencv directly if you're okay with C++). I find that this works much better than the automatic thresholding options that come with FIJI, especially since in my images there is a lot of variation in how darkly cells were stained in different brains or different brain areas. We will create the cell mask starting from the brightfield image. The steps for creating the mask are as follows:

1. Invert image (the adaptive thresholding expects a dark background.)
2. Subtract background (rolling-ball 300px).
3. Run adaptive thresholding
4. Subtract very small objects. These are grains that are not over cells. We don't want these as part of our cell mask.
5. Dilate the remaining objects. We do want to capture grains that are very close to the cell borders, these are likely relavant grains.
6. Save thresholded mask for use in step 3.

My imageJ macro looks like this:
~~~~~~~~
function makeCellMask(inputx, outputx, filenamex){
	open(inputx + filenamex);
	run("Invert");
	run("Subtract Background...", "rolling=300");
	run("adaptiveThr ", "using=[Weighted mean] from=501 then=1");
	run("Analyze Particles...", "size=200-Infinity pixel show=Masks");
	run("Dilate");
	run("Invert");
	saveAs("tif", outputx+filenamex);
	close();
}

inputx = "/Users/seanmaguire/Documents/df_methods_comparison/green_input/" ; 
outputx = "/Users/seanmaguire/Documents/df_methods_comparison/green_output/";
setBatchMode(true);
list2 = getFileList(inputx);
for (i = 0; i < list2.length; i++)
        makeCellMask(inputx, outputx, list2[i]);
setBatchMode(false);
~~~~~~~~~

Now we have a new file saved which is the cell mask. The next step is going to be to separate overlapping silver grains in the darkfield image. For this we're going to use the [findFoci plugin](http://www.sussex.ac.uk/gdsc/intranet/microscopy/imagej/findfoci). We'll be able to separate overlapping grains because the center of each grain is brighter than the edges. Thus we can ID individual grains and separate them. A schematic of how it works (from the findFoci manual):

![peaks]({{smmaguire.github.io}}/assests/find_peaks.tiff)

So we can use this to segment and count the overlapping grains. Here is the code I use:
~~~~~~~~~~~~~~~
run("FindFoci", "mask=(None) background_method=[Auto threshold] background_parameter=2.5 auto_threshold=Otsu statistics_mode=Both search_method=[Above background] search_parameter=0.4 minimum_size=3 minimum_above_saddle minimum_peak_height=[Relative above background] peak_parameter=0.0 sort_method=[Total intensity] maximum_peaks=10000 show_mask=[Peaks above saddle] overlay_mask fraction_parameter=0.001 show_table clear_table mark_maxima show_log_messages gaussian_blur=0.0 centre_method=[Max value (search image)] centre_parameter=2.0");
~~~~~~~~~~~~~~~~

Before segmentation:

![before]({{smmaguire.github.io}}/assests/before_seg.jpg)

And After segmentation:

![after]({{smmaguire.github.io}}/assests/after_seg.jpg)

Okay thats pretty much it! You can use the findFoci batch mode and supply the masks from step 1 to do the mask subtraction.
