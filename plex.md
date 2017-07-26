# Settings & Configurations for Plex Media Server

## Install Plex Media Server

1. 

## Plex Media Server web portal

http://192.168.1.11:32400/web/index.html

## How to update Headless Plex Media Server

1. `$ ssh mediaserver`
2. `$ wget https://downloads.plex.tv/plex-media-server/---/plexmediaserver---.deb`
3. `$ sudo dpkg -i plexmediaserver_---.deb`

Replace `---` with the current release found at https://www.plex.tv/downloads/

## HandBrakeCLI settings for Plex Media Server

1. Rip DVD using MakeMKV
2. `HandBrakeCLI --encoder x265 --encoder-preset slower --encoder-profile main --quality 20.0 --comb-detect --decomb --aencoder copy:ac3 -i ./file.mkv -o ./new_file.mkv`

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
