# Special-Peak-Detector

**Inputs**: A signal of unknown origin sampled at a rate of 10Hz and stored in the file "signal.csv"

**Description**: You are asked to implement a process which takes the input signal and finds the signal’s “special” peak from a set of “valid” peaks. Here is how to find valid peaks:

1) Find the largest undesignated peak in the signal (this will simply be the largest peak to start with). This peak is designated as valid and has amplitude A<sub>n</sub>.

2) Remove from consideration all peaks within ±5s of the valid peak found in step 1 whose amplitude is greater than A<sub>n</sub>/2 (this includes peaks exactly ±5s from the valid peak)
3) Repeat steps 1 and 2 until all peaks have either been designated as valid or removed. 

4) The special peak is the valid peak with the smallest amplitude.

**Output**: A single value containing the 1-based sample index at which the special peak occurs. If more than one peak meets the special peak criteria, return the one which is closest to the beginning of the signal.

![AllPeaks](https://user-images.githubusercontent.com/63022731/94362722-33c8c700-0072-11eb-929b-0834425da082.jpg)
![ValidSpecialPeaks](https://user-images.githubusercontent.com/63022731/94362720-33303080-0072-11eb-9e1b-1a4a9d47f705.jpg)
