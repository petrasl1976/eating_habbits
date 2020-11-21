#!/usr/local/bin/bash
usage () {
	echo "Script will draw timetable of photos in the folder based on exif DateTimeOriginal value."
	echo
	echo "Usage: $0 [-d <folder>] [-s <step>] [-w <pos>]"
	echo 
	echo "   -d   - folder with photos to analyze. Default - curremnt folder"
	echo "   -s   - step of y ruller. Default - 30 min"
	echo "   -w   - wrap position. Default - terminal resolution"
	echo
	echo "My intend idea was to visualize my eating habbits. Therefore I take photo of each my snack, lunch, ..."
	echo "After a week or so i run this script against those photos and get simple chart."
	echo "It will allow to se eating irregularities, dispersion during the day."
	exit
}

while getopts "d:s:w:hi" opt; do
	case "$opt" in
	d) dir=${OPTARG} ;;
	s) step=${OPTARG} ;;
	w) wrappos=${OPTARG} ;;
	i) info=true ;;
	*) usage ;;
	esac
done

dir=${dir:-"."}							# default current folder
step=${step:-30}						# default y ruller step 30 mins
termsize=$(tput cols)						# terminal column count
((days=termsize-9))						# days fit to terminal (from right to left) = terminal column count - time tittle
days=${wrappos:-$days}						# default chart width - terminal size

[[ -z $info ]] || { echo "d=$dir, s=$step, w=$days"; exit 0; }	# info for debug

dmins=0								# minute of the day (y axis from top to down)
declare -A matrix						# files could be sorted not by time it was taken
declare -A maxy
declare -A miny

[[ -z "$dir" ]] && usage					# 1-st argument must be provided
[[ -d "$dir" ]] || usage					# argument should point to the existing folder

tday=$(date "+%j")						# todays day of the year

for f in "$dir"/*.jpg						# go through each *.jpg file in given folder
do
	read x x fy fm fd fh fi x <<< $(exiftool -DateTimeOriginal "$f"|tr \: \  ) \
		|| { echo not JPG $f; continue; }		# try to get timestamp of the image it was taken and note its Y m d H and I
	fday=$(gdate -d "$fy-$fm-$fd" +%j)			# day of the year photo was taken
	(( age = tday - fday ))					# age of photo in days
	[[ $age -gt $days ]] && echo OutOfRange $f && continue	# skip if photo older than we can fit in to terminal
	(( ypos = ( 10#$fh * 60 + 10#$fi ) / step ))		# minute of the day photo was taken rounded by $step. Make sue 0 willnot be threated as octal number
	((matrix[$age,$ypos]++))				# ++ to cell of the matreix
done

((s=days%7+8))							# Extra spaces and " time | " char count 
printf "%-${s}s" "tm\dt | " 					# Time column header with extra spaces left after x/7
for (( x=(days/7*7); x>0; x=x-7 )) 				# print days back each 7 starting x*7
do
	rtime=$(gdate -d "$x days ago" +%m.%d)
	printf "%-7s" $rtime					# print age ruler (header of the matrix)
done
echo "|"							# border of the header

for (( x=0; x<=days; x++ )) 					# find first and last meal this day
do
	miny[$x]=$(printf "%s\n" ${!matrix[@]}|grep "^$x,"|cut -d, -f2|sort -nr|tail -1) # find last meal this day
	maxy[$x]=$(printf "%s\n" ${!matrix[@]}|grep "^$x,"|cut -d, -f2|sort -n|tail -1)  # find first meal this day
	for (( ty=miny[$x]; ty<maxy[$x]; ty++ ))		# fill matrix betwean first and last meals with 0,...
	do
		matrix[$x,$ty]=${matrix[$x,$ty]:-0}		# ... if cell not yet has any value
	done
done

for (( y=0; y<=24*60/step; y++ ))				# print 24h each $step mins (24*60/$step)
do
	printf "%02d:%02d | " $dhour $dmin			# line tittle
	(( dmins = dmins + step ))          			# increase minutes of the day by $step
	(( dhour = dmins / 60 ))          			# lets find which hour it is
	(( dmin = dmins % 60 ))           			# and how much mins left to full hour
	for (( x=days; x>0; x-- ))        			# days = terminal 
	do
		echo -n ${matrix[$x,$y]:-" "}			# print value of the cell
	done
	echo "|"						# border of the matrix
done