# HandBrakeCLI on headless ubuntu server

## Configure setting on HandBrake GUI (Optional) and export

This is an optional step, but it's a lot easier to set up configurations in the GUI than trying to read through and understand a billion CLI options and switches.

Once you have a good setup you are happy with using the GUI, load the preset then go to Preset -> Export to file -> preset_name.json

## Copy preset to headless server

`$ scp ~/Desktop/preset_name.json pconwell@mediaserver:`

## Rip legally owned copies of DVDs to mediaserver

MakeMKV blah blah... maybe there is a CLI? Either way, using MakeMKV get the .mkv to mediaserver:/temp_storage/temp_videos/

## HandBrakeCLI

The CLI doesn't appear to import preset_name.json correctly. So, for now use

`$ HandBrakeCLI -e x265 -i /temp_storage/temp_videos/Ghost.mkv -o /videos/Movies/Ghost.mkv`

`$ HandBrakeCLI --encoder x265 --encoder-preset slower --encoder-profile main --quality 20.0 --comb-detect --decomb --aencoder copy:ac3 -i /temp_storage/temp_videos/file.mkv -o /videos/Movies/file.mkv

instead of

~~$ HandBrakeCLI --preset-import-file ./preset_name.json -i /temp_storage/temp_videos/filename.mkv -o /videos/Movies/filename.mkv~~

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
| 50      |        |       |
| 45      |        |       |
| 40      |        |       |
| 35      |        |       |
| 30      |        |       |
| 25      |        |       |
| 20      |        |       |
| 15      |        |       |
| 10      |        |       |
| 5       |        |       |
| 1       |        |       |

## Bash script

```
#!/bin/bash
#

file=file.mkv
url=https://maker.ifttt.com/trigger/handbrake/with/key/{{key}}

action=started
curl $url'?value1='$action'&value2='$file

HandBrakeCLI --encoder x265 --encoder-preset slower --encoder-profile main --quality 20.0 --comb-detect --decomb --aencoder copy:ac3 -i /temp_storage/temp_videos/file.mkv -o /videos/Movies/file.mkv

action=finished
curl $url'?value1='$action'&value2='$file

```
