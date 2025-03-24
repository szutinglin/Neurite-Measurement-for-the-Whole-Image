# Neurite-Measurement-for-the-Whole-Image
![image](https://github.com/user-attachments/assets/3566f36d-1626-4b0e-9c97-a3e43e55600a)


This Fiji batch macro is designed to process neuron images with extensive clustering, especially those with low-contrast neurites.
By utilizing the Local Thickness [1] and Skeletonize [2] plugins, we have developed a workflow for whole-image neurite measurement. The automatically saved Excel file provides the total neurite length and cell count for the entire image.

# Examples
1.	The confocal image of SH-SY5Y cells was acquired using high-content imaging courtesy of Dr. Ling-Wei Hsin (National Taiwan University. School of Pharmacy, College of Medicine).

# Description 
1.	This is a batch IJM script. 
2.	The demo image contains two channels: SH-SY5Y cells (green) and DAPI (blue).
3.	The script begins by splitting the channels and renaming them accordingly.
4.	Then creating neuron mask by using the RenyiEntropy[3] thresholding method.
5.	The neuron mask is duplicated, and local thickness is applied to approximate the soma mask.
6.	The neuron mask is skeletonized, and the soma mask is subtracted to isolate the neurites.
7.	The total length of the neurites is measured.
8.	Otsu[4] thresholding is applied to the DAPI channel, and the result is converted to a mask.
9.	The DAPI mask is multiplied with the normalized neuron mask to identify DAPI-positive regions.
10.	Segmentation of the DAPI-positive regions is performed using StarDist[5].
11.	The total cell count is determined, and the average neurite area per cell is calculated.
12.	All measurements are saved in a batch table.
13.	A composite image is generated to visualize the results: raw neurons in white, segmented DAPI in the glasbey on dark channel, and neurites in red.
14.	Both the composite image and batch table are saved in the same output file.

# Instruction
1.	Place the image in the same directory for batch analysis. Also, create a null file to serve as the output file. 
2.	Drag the script and the demo image to Fiji.
3.	Press “Run” and choose the input and output file respectively.
4.	The batch results will be saved as an Excel file. 

# Acknowledgements
Thank to Dr. Shao-Chun, Peggy, Hsu, and Ms. Archi Luo for their invaluable teaching and guidance!
Demo image are the courtesy from Dr. Ling Wei Hsin (National Taiwan University. School of Pharmacy, College of Medicine) .

# Reference
1.	R. P. Dougherty and K.-H. Kunzelmann, "Computing Local Thickness of 3D Structures with ImageJ," in Microscopy & Microanalysis 2007 Meeting, Ft. Lauderdale, FL, USA, Aug. 2007. 
2.	T. Y. Zhang and C. Y. Suen, "A fast parallel algorithm for thinning digital patterns," Communications of the ACM, vol. 27, no. 3, pp. 236–239, 1984. 
3.	P. Sahoo, C. Wilkins, and J. Yeager, "Threshold selection using Renyi's entropy," Pattern Recognition, vol. 30, no. 1, pp. 71–84, Jan. 1997, doi: 10.1016/S0031-3203(96)00065-9. 
4.	N. Otsu, "A threshold selection method from gray-level histograms," IEEE Transactions on Systems, Man, and Cybernetics, vol. 9, no. 1, pp. 62–66, 1979, doi: 10.1109/TSMC.1979.4310076.
5.	M. Weigert and U. Schmidt, "Nuclei Instance Segmentation and Classification in Histopathology Images with Stardist," in 2022 IEEE International Symposium on Biomedical Imaging Challenges (ISBIC), Kolkata, India, 2022, pp. 1–4, doi: 10.1109/ISBIC56247.2022.9854534. 
