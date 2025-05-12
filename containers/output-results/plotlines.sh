#!/bin/bash
#echo "Syntax: ./plotfigure filename title striptitle transpose omitlineskeyword removekeyword xlabel ylabel xrange yrange boxvertical boxhorizontal xticksrotate column1title column1position column2title column2position column3title column3position column4title column4position"

if (( $# < 6 )); then
  echo "Syntax: ./plotfigure filename title striptitle transpose filterkeyword removekeyword xlabel ylabel xrange yrange boxvertical boxhorizontal column1title column1position column2title column2position column3title column3position ..."
  exit 1
fi

filename=$1
title="$2"
striptitle=$3
transpose=$4
filterkeyword=$5
removekeyword=$6
xlabel="$7"
ylabel="$8"
xrange=$9
yrange=${10}
boxvertical=${11}
boxhorizontal=${12}
xticksrotate=${13}

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

if [[ $filterkeyword != "no" ]] && [[ $filterkeyword != "" ]]; then
  echo "filter (exclude) lines with particular keyword"
  grep -v "$filterkeyword" $filename > /tmp/tempfile 
  mv /tmp/tempfile $filename.o
  filename=$filename.o
fi

if [[ $removekeyword != "no" ]] && [[ $removekeyword != "" ]]; then
  echo "remove text with particular keyword"
  sed -i "s/$removekeyword//" "$filename"
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
  echo "set xtics font 'Courier,14'" >> plot.p 
else
  echo "set xtics font 'Courier,14' rotate by $xticksrotate" >> plot.p
fi
echo "set ytics font 'Courier,14'" >> plot.p
echo "set xlabel font 'Courier,18'" >> plot.p
echo "set ylabel font 'Courier,18'" >> plot.p
echo "set title font 'Courier,18'" >> plot.p
echo "set key font 'Courier,14'" >> plot.p
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

# Regex for a number: optional digits, optional decimal part
number_regex='^[0-9]+(\.[0-9]+)?$'

if [[ "$boxvertical" =~ $number_regex ]] && [[ "$boxhorizontal" =~ $number_regex ]]; then
  # both parameters are numeric
  echo "set key at graph ${boxvertical}, ${boxhorizontal}" >> plot.p
else
  # parameters are not numeric
  echo "set key $boxvertical $boxhorizontal" >> plot.p
fi
#echo "set key box" >> plot.p

./setlinestyles

# plot first curve
echo "plot '$filename' using ${15}:xtic(1) title '${14}' with linespoints ls 1\\" >> plot.p

# plot remaining figures
linecount=2
for ((i = 16; i <= $#; i+=2)); do
    column_title=${!i}
    nexti=$((i+1))
    column_position=${!nexti}
    echo ", '$filename' using ${column_position} title '${column_title}' with linespoints ls $linecount\\" >> plot.p
    let linecount=linecount+1
done

# Remove the trailing backslash
sed -i '$s/\\\s*$//' plot.p

#gnuplot plot.p

