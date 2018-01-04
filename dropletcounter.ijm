/*
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 3 of the License, or
 * (at your option) any later version.
 * 
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 * 
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston,
 * MA 02110-1301, USA.
 * 
 */
 
// Author: Henry Korhonen henryk@student.ethz.ch

// in order to get more detailed information on the functions used here, visit:
// https://imagej.nih.gov/ij/developer/macro/functions.html 
// note that there are many values in this code that are specifically fitting for
// certain test pictures (.
macro "dropletcounter"	{
	
autoUpdate(true);

selectWindow("test.tif");
	// hough trafo needs binary pics
run("Make Binary");
	// skeletons will less likely lead to "phantom circles"
run("Skeletonize");

	// hardcoded max and min radii of the droplets.
	// the loop will be executed for radius intervals
	// and optionally for threshold level intervals (simply add a while loop accordingly)
rmin = 3;
rmax = 35;
looprmax = rmin + 3; // set the initial value for rmax used in the loop. the initial value pair for
	// the r-loop will be [rmin, rmin+5], second will be [rmin+5, rmin+10] etc. for example.


	// find circles (hough trafo), paint over and repeat for relevant intervals
old_ncurrentcircle = 0; //as the list begins with the 0th row and ends with ncircles-1
ncurrentcircle = 0;
looprmin = rmin;
while (looprmax < rmax) {
Hthreshold = 0.4; // alter this in order to build in a for loop for threshold levels
		//maybe delete the "show mask", afaik that's the original pic with the crosses (centers) and radii
	//selectWindow("test.tif");
	run("Hough Circle Transform","minRadius=" + looprmin + ", maxRadius=" + looprmax + ", inc=1, minCircles=0, maxCircles=65535, threshold=" + Hthreshold + ", resolution=161, ratio=1.0, bandwidth=10, local_radius=10,  reduce show_mask results_table");

	looprmin = looprmax;
	looprmax = looprmax + 3;

		// determine the number of circles and erase them from the original bin pic
		// after testing, maybe add +1 to ncircles in the second argument of the following for loop

updateResults();
wait(5000); // this is needed, as the script runs further even if the HCT is still running
			// there should be some way to overcome this limitation
ncc = 1;
ncircles = getValue("results.count");
	print(ncircles);
while (ncc < ncircles)	{
	
		setColor(255,255,255);
		//setColor(0,0,0) for black background
		// careful when defining the radii, x and y values: µm or pixels!
		//r = getResult("Radius (µm)",ncc);
		r = getResult("Radius (pixels)",ncc);

		//x = getResult("X (µm)",ncc);
		//y = getResult("Y (µm)",ncc);

		x = getResult("X (pixels)",ncc);
		y = getResult("Y (pixels)",ncc);

			//fillOval will draw a filled circle above the detected circle specified above
			//specify the top left corner of the square where the filled circle will be drawn in
		xd = floor(x - r)-4;
		yd = floor(y - r)-4;
			// the r/5 value should be adjusted to the resolution of the bin pic
			// it ensures that the whole detected circle is being covered by the filled circle
		d = floor(2*r) + 10;
			// filled circles are being drawn on the original image
		selectWindow("test.tif");
		fillOval(xd, yd, d, d);
		ncc++;
	}
	//old_ncurrentcircle = ncurrentcircle;
		//if (rmin < 15){ //this might be unnecessary.
		//	rmin = rmin + 5;}
		//else {
		//	rmin = rmin +10;}
		

}
}
