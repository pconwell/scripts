# HandBrakeCLI on headless ubuntu server

## Rip legally owned copies of DVDs to mediaserver

1. Put DVD in computer
2. Open MakeMKV
3. ...
4. Copy to Z:/temp_videos/filename.mkv

## HandBrakeCLI

### Bash script

```bash
#!/bin/bash
#

iftttURL=https://maker.ifttt.com/trigger/handbrake/with/key/your_ifttt_key_here

LIST='/temp_storage/temp_videos/*.mkv';
for z in $LIST; do

action=started;
curl $iftttURL"?value1="$action"&value2="$(basename $z);

HandBrakeCLI --encoder x265 --encoder-preset slower --encoder-profile main --quality 20.0 --comb-detect --decomb --aencoder copy:ac3 -i "$z" -o /videos/Movies/"$(basename $z)";

mv "$z" "$z.bak";

action=finished;
curl $iftttURL"?value1="$action"&value2="$(basename $z);

done;


```

### x265 Options

#### --encoder-preset

9,561,744 byte source file, all settings default

| Preset        | Size (bytes)  | Time (s)|
| ------------- |:-------------:| ------: |
| ultrafast     | 858,099       | 34      |
| superfast     | 884,929       | 48      |
| veryfast      | 864,552       | 68      |
| faster        | 821,033       | 67      |
| fast          | 840,712       | 94      |
| medium        | 864,552       | 113     |
| slow          | 813,891       | 362     |
| slower        | 808,952       | 978     |
| veryslow      | 810,634       | 1,571   |
| placebo       | 838,735       | 6,145   |

#### --quality

9,561,744 byte source file, all settings default

| Quality | Size (bytes)  | Time (s)|
| ------- |:-------------:| ------: |
| 50      | 863,094       | 20      |
| 45      |               |         |
| 40      |               |         |
| 35      |               |         |
| 30      |               |         |
| 25      |               |         |
| 20      | 1,879,492     | 43      |
| 15      |               |         |
| 10      |               |         |
| 5       |               |         |
| 1       | 9,294,587     | 68      |


