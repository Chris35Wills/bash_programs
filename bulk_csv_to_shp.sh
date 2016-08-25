#!/usr/bin/env bash

# Creates ESRI Shapefile format vector files from csv files
# Output shapefile will be put into the samee directory as the input files
#
# VARIABLES
#	search_string -- path to csv files which have x and y columns in a known projection e.g. /path/to/files/*.csv
#	x_col_name    -- column header containing x coordinates e.g. coord_x
#	y_col_name    -- column header containing y coordinates e.g. coord_y
#	proj_string="+proj=stere +lat_0=90 +lat_ts=71 +lon_0=-39 +k=1 +x_0=0 +y_0=0 +datum=WGS84 +units=m +no_defs" -- PROJ4 string stating the coordinate system of the points
#
# Example usage:
# 	sh bulk_csv_to_shp.sh -s /path/to/files/* -x coord_x -y y_coord -p '+proj=stere +lat_0=90 +lat_ts=71 +lon_0=-39 +k=1 +x_0=0 +y_0=0 +datum=WGS84 +units=m +no_defs'


# convert to function
# variables (modify to pass in at command line):
# see: http://stackoverflow.com/questions/7529856/bash-getopts-retrieving-multiple-variables-from-one-flag
# see: http://wiki.bash-hackers.org/howto/getopts_tutorial
# see: http://stackoverflow.com/questions/192249/how-do-i-parse-command-line-arguments-in-bash
#<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
#<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< FIX VARIABLE READ IN
#<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
#while getopts ":s:x:y:p" opt; do
#  case $opt in
#  	s)
#      echo "-search_string was triggered!" #>&2
#      search_string="$OPTARG" # set variable from option...
#      ;;
#    x)
#      echo "-x flag triggered!" #>&2
#      x_col_name="$OPTARG" # set variable from option...
#      ;;
#    y)
#      echo "-y flag triggered!" #>&2
#      y_col_name="$OPTARG" # set variable from option...
#      ;;
#    p)
#      echo "-proj flag triggered!" #>&2
#      proj_string="$OPTARG" # modify to accept gaps
#      ;;
#    \?)
#      echo "Invalid option: -$OPTARG" #>&2
#      ;;
#  esac
#done
#echo "Variables as passed in:"
#echo "File search string: " $search_string
#echo "x coordinate column header: " $x_col_name
#echo "y coordinate column header: "$y_col_name
#echo "PROJ4 string: " $proj_string
#
#echo $proj_string
#
#exit
#<<<<<<<<<<<<<<<<<
#<<<<<<<<<<<<<<<<<<<<< END OF ISSUE
#<<<<<<<<<<<<<<<<<
##~~~~~~~~~~~~

#<<<<<<<<<<<<<<<<<<
#<<<<<<<<<<<<<<<<<<<<< REPLACE WITH COMMAND LINE OPTIONS ABOVE
#<<<<<<<<<<<<<<<<<<
search_string='C:/GitHub/synthetic_channels/FENTY_DEM_along_track_FT/run_3/paths/*.csv'
x_col_name='coord_x'
y_col_name='coord_y'
proj_string='+proj=stere +lat_0=90 +lat_ts=71 +lon_0=-39 +k=1 +x_0=0 +y_0=0 +datum=WGS84 +units=m +no_defs'
#<<<<<<<<<<<<<<<<<<
#<<<<<<<<<<<<<<<<<<<<< END OF ISSUE
#<<<<<<<<<<<<<<<<<<

FILES=$search_string

echo "Files to work on:"
echo $FILES

for i in $FILES;
do 

stripped_ext=`basename $i .csv`
stripped_dir=`basename $i`

echo "Working on $i"

cd `dirname $i`

dir=${PWD##*/}

echo "Now in directory: $dir"

# create dbf file
echo "creating dbf file..."
ogr2ogr -f "ESRI Shapefile" ${i%.csv}.dbf $stripped_dir

#done

# make new vrt file
echo "writing vrt file..."
echo "<OGRVRTDataSource>" > ${i%.csv}.vrt
echo "  <OGRVRTLayer name="\"$stripped_ext\"">" >> ${i%.csv}.vrt # stripped_ext
echo "    <SrcDataSource>$stripped_dir</SrcDataSource>" >> ${i%.csv}.vrt  # striped_dir
#echo "    <SrcDataSource>$i</SrcDataSource>" >> ${i%.csv}.vrt  # striped_dir
echo "    <SrcLayer>$stripped_ext</SrcLayer>" >> ${i%.csv}.vrt # stripped_ext
echo "    <GeometryType>wkbPoint</GeometryType>" >> ${i%.csv}.vrt
echo "    <LayerSRS>$proj_string</LayerSRS>" >> ${i%.csv}.vrt # proj_string
echo "    <GeometryField encoding=\"PointFromColumns\" x=\"$x_col_name\" y=\"$y_col_name\"/>" >> ${i%.csv}.vrt # x_col_name, y_col_name
echo "  </OGRVRTLayer>" >> ${i%.csv}.vrt
echo -n "</OGRVRTDataSource>" >> ${i%.csv}.vrt # no new line after this 

# create shp file
echo "creating shp file..."
echo ${i%.csv} 
echo ${i%.csv}.vrt
ogr2ogr -f "ESRI Shapefile" ${i%.csv} ${i%.csv}.vrt; ## this bit won;t work..... unable to open datasource *.vrt

cd -;
done
