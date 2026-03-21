pragma Singleton
import Quickshell
import Quickshell.Io
import QtQuick

Singleton {
    id: root

    property int barCount: 20
    property list<int> values: Array(barCount)


    Process {
        id: cavaProc
        command: ["sh", "-c", `printf '[general]\nframerate=60\nbars=${root.barCount}\nsleep_timer=3\n[output]\nchannels=mono\nmethod=raw\nraw_target=/dev/stdout\ndata_format=ascii\nascii_max_range=20\n[smoothing]\nnoise_reduction=12' | cava -p /dev/stdin`]
        stdout: SplitParser {
            onRead: data => {
                root.values = data.slice(0, -1).split(";").map(v => parseInt(v, 10));
            }
          }
        running: MprisService.activePlayer?.isPlaying

    }
}
