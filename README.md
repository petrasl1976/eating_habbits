ABOUT:

Bash shell script to visualize your eating habbit.

Data source for script - DateTimeOriginal (exif) of photos of meals you enjoyed.

My intend was to visualize my eating habbits. I take a photo of each my snack, lunch, ...

After a week or so i run this script against folder with those photos and get simple chart.

It will allow to se eating irregularities, dispersion during the day, eating window size.

OUTPUT EXAMPLE:
```
T0490:eating_habbits t0490$ ./eating_habbits.sh -d ../Downloads/aaa/Camera/ -s 120 -w 50
tm\dt |  10.03  10.10  10.17  10.24  10.31  11.07  11.14  |
00:00 |                                                   |
02:00 |                                                   |
04:00 |                                                   |
06:00 |                1      1        11                 |
08:00 |         1111111011111101111111100211111 11        |
10:00 |         0000000000000000001000001000010100        |
12:00 |         1120003200110010110000000000004002        |
14:00 |         0000000011001100000111111110002021        |
16:00 |         00000000000000010000000000000000 0        |
18:00 |         10001100010000011111110000100000 1        |
20:00 |          111  011 11011   0   1122 00010          |
22:00 |               1     1     1        11  2          |
24:00 |                                                   |
```
 * folder with photos `../Downloads/aaa/Camera/`
 * y step `120` min
 * x width `50` days

TODO:

add option to hide 0. This will give a bit more clear view when you chewing something.

CONCLUSION:

Bash is not the best scripting language to operate with arrays and display similar information, but still possible to get expected result with simple tools.

Feel free to improve and share :)
