# -*- coding: utf-8 -*-

import sys

input_file = sys.argv[1]
output_file = sys.argv[2]
print('in:  ' + input_file)
print('out: ' + output_file)
with open(output_file, 'w') as fw:
    with open(input_file) as fr:
        for line in fr.readlines():
            values = line.split(',')
            if int(values[3]) < -32768:
                values[3] = '-32768'
            fw.write(','.join(values))
            
