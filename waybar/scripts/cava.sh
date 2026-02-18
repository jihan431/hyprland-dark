#! /bin/bash

bar="▁▂▃▄▅▆▇█"
dict="s/;//g;"

# creating "dictionary" to replace char with bar
i=0
while [ $i -lt ${#bar} ]
do
    dict="${dict}s/$i/${bar:$i:1}/g;"
    i=$((i=i+1))
done

# write cava config
config_file="/tmp/polybar_cava_config"
echo "
[general]
bars = 12

[output]
method = raw
raw_target = /dev/stdout
data_format = ascii
ascii_max_range = 7
" > $config_file

# read stdout from cava
cava -p $config_file | while read -r line; do
    # Check if the line is all zeros (silence)
    # Removing all 0s and ;s. If the result is empty, it's silent.
    is_silent=$(echo "$line" | sed 's/[0;]//g')

    if [ -z "$is_silent" ]; then
        echo ""
    else
        echo $line | sed $dict
    fi
done