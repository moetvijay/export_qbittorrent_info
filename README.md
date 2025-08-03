# export_qbittorrent_info
The DOS script aims to export basic information related to files downloaded using qBittorrent on a windows machine.
It looks for the download path of the file upon completion, and creates a .json file with details like:
  torrent name,
  torrent hash,
  total size,
  files list, their size and extension

Use:
  Save the script somewhere on your PC and set up qBittorrent to run the saved script along with follwing parameters
  "\some\directory\InfoExport.bat" "%N" "%D" "%I" "%F"
Note: Do not change the sequence of the parameters, their positions are locked with the script
