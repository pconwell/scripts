## HandBrakeCLI on headless ubuntu server

### Configure setting on HandBrake GUI (Optional) and export

This is an optional step, but it's a lot easier to set up configurations in the GUI than trying to read through and understand a billion CLI options and switches.

Once you have a good setup you are happy with using the GUI, load the preset then go to Preset -> Export to file -> preset_name.json

### Copy preset to headless server

`$ scp ~/Desktop/preset_name.json pconwell@mediaserver:`

### Rip legally owned copies of DVDs to mediaserver

MakeMKV blah blah... maybe there is a CLI? Either way, using MakeMKV get the .mkv to mediaserver:/temp_storage/temp_videos/

### HandBrakeCLI

The CLI doesn't appear to import preset_name.json correctly. So, for now use

`$ HandBrakeCLI -e x265 -i /temp_storage/temp_videos/Ghost.mkv -o /videos/Movies/Ghost.mkv`

instead of

~~$ HandBrakeCLI --preset-import-file ./preset_name.json -i /temp_storage/temp_videos/filename.mkv -o /videos/Movies/filename.mkv~~
