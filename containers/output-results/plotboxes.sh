#!/bin/bash
#echo "Syntax: ./plotfigure filename transpose striptitle title xlabel ylabel xrange yrange boxvertical boxhorizontal xticksrotate column1title column1position column2title column2position column3title column3position column4title column4position"

if (( $# < 6 )); then
  echo "Syntax: ./plotfigure filename transpose striptitle title xlabel ylabel xrange yrange boxvertical boxhorizontal column1title column1position column2title column2position column3title column3position ..."
  exit 1
fi

filename=$1
transpose=$2
striptitle=$3
title="$4"
xlabel="$5"
ylabel="$6"
xrange=$7
yrange=$8
boxvertical=$9
boxhorizontal=${10}
xticksrotate=${11}

# set full path of filename
filename="/root/results/$filename"

if [[ $striptitle == "yes" ]]; then        
  echo "striping out first line"           
  cat $filename | tail -n +2 > /tmp/tempfile
  mv /tmp/tempfile $filename.s
  filename=$filename.s               
fi  

if [[ $transpose == "yes" ]]; then                                                                                                         
  echo "transposing file"                               
  ./transpose.sh $filename /tmp/tempfile
  mv /tmp/tempfile $filename.t            
  filename=$filename.t                             
fi                                                      
                                                        
# output of processed file is now:                                                           
#cat $filename

# create plot.p
#echo "set terminal png" > plot.p         
#echo "set output 'output.png' >> plot.p  

#echo "set term postscript eps color" > plot.p
echo "set term postscript eps solid" > plot.p
echo "set autoscale" >> plot.p
echo "unset log" >> plot.p
echo "unset label" >> plot.p
echo "set xtic auto" >> plot.p
if [[ $xticksrotate == "" ]] || [[ $xticksrotate == "no" ]]; then
  echo "set xtics font 'Arial,14'" >> plot.p 
else
  echo "set xtics font 'Arial,14' rotate by $xticksrotate" >> plot.p
fi
echo "set ytics font 'Arial,14'" >> plot.p
echo "set xlabel font 'Arial,18'" >> plot.p
echo "set ylabel font 'Arial,18'" >> plot.p
echo "set title font 'Arial,18'" >> plot.p
echo "set key font 'Arial,16'" >> plot.p
echo "set ytic auto" >> plot.p
echo "set title '$(echo $title)'" >> plot.p
echo "set xlabel '$(echo $xlabel)'" >> plot.p
echo "set ylabel '$(echo $ylabel)'" >> plot.p
if [[ $yrange != "auto" ]]; then
  echo "set yrange $yrange" >> plot.p
fi
#echo "set yrange [0:1000]" >> plot.p
if [[ $xrange != "auto" ]]; then
  echo "set xrange $xrange" >> plot.p
fi
#echo "set xrange [0:30]" >> plot.p
echo "set key $boxvertical $boxhorizontal" >> plot.p
#echo "set key box" >> plot.p



echo "set style data histogram" >> plot.p
echo "set style histogram rowstacked" >> plot.p
#echo "set style histogram cluster gap 1" >> plot.p
echo "set style fill pattern border -1" >> plot.p
echo "set boxwidth 0.4" >> plot.p

./setlinestyles

# Get the number of communication types
num_communication_types=$(((($# - 11) / 2) - 1))

# Calculate the width of each network plugin box
box_width="0.8 / ($num_communication_types + 1)"

# Create plot command
plot_command="plot"
linecount=0
for ((i = 12; i <= $#; i+=2)); do
  column_title=${!i}
  nexti=$((i+1))
  column_position=${!nexti}

  # Calculate the position of the network plugin box
  box_position="$column_position - (($num_communication_types - 1) / 2) + ($linecount * $box_width)"

  plot_command+=" '$filename' using ($box_position + ($linecount * $box_width)):$column_position:xtic(1) title '$column_title' with boxes ls $((linecount+1)),"
  let linecount=linecount+1
done

# Remove the trailing comma
plot_command=${plot_command%?}

# Append the plot command to plot.p
echo "$plot_command" >> plot.p

exit 0

# plot first curve
echo "plot '$filename'  using ${13}:xtic(1) title '${12}' with linespoints ls 1\\" >> plot.p

# plot remaining figures
linecount=2
for ((i = 14; i <= $#; i+=2)); do
    column_title=${!i}
    nexti=$((i+1))
    column_position=${!nexti}
    echo ", '$filename'  using ${column_position} title '${column_title}' with linespoints ls $linecount\\" >> plot.p
    let linecount=linecount+1
done

# Remove the trailing backslash
sed -i '$s/\\\s*$//' plot.p

#gnuplot plot.p

