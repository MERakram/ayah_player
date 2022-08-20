import 'package:flutter/material.dart';
import 'package:flutter_offline/flutter_offline.dart';
import 'package:just_audio/just_audio.dart';
import 'package:rxdart/rxdart.dart';
import 'component/common.dart';
import 'edition_list.dart';
import 'component/neu_container.dart';
import 'component/snack_bars.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: editions_page(),
    );
  }
}

class player_page extends StatefulWidget {
  final edition;
  final ayahs_number;
  final first_ayahs_index;
  final last_ayahs_index;

  player_page(this.edition, this.ayahs_number, this.first_ayahs_index,
      this.last_ayahs_index);

  @override
  State<player_page> createState() => _player_pageState();
}

class _player_pageState extends State<player_page> {
  List<AudioSource> ayahs_list = [];
  final _player = AudioPlayer();
  int co = 0;
  bool isPlaying = false;
  bool isLooping = false;

  Stream<PositionData> get _positionDataStream =>
      Rx.combineLatest3<Duration, Duration, Duration?, PositionData>(
          _player.positionStream,
          _player.bufferedPositionStream,
          _player.durationStream,
          (position, bufferedPosition, duration) => PositionData(
              position, bufferedPosition, duration ?? Duration.zero));

  @override
  void initState() {
    super.initState();
    co = widget.first_ayahs_index;
    for (int i = widget.first_ayahs_index; i <= widget.last_ayahs_index; i++) {
      ayahs_list.add(
        AudioSource.uri(
          Uri.parse(
              'https://cdn.islamic.network/quran/audio/128/${widget.edition}/$i.mp3'),
        ),
      );
    }
    // Define the playlist
    final playlist = ConcatenatingAudioSource(
      // Start loading next item just before reaching it
      useLazyPreparation: true,
      // Customise the shuffle algorithm
      shuffleOrder: DefaultShuffleOrder(),
      // Specify the playlist items
      children: ayahs_list,
    );
    _player.setAudioSource(playlist,
        initialIndex: 0, initialPosition: Duration.zero);
  }

  Widget buildPlayer() {
    return Scaffold(
        backgroundColor: Colors.grey[300],
        body: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 25),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                SizedBox(
                  height: 30,
                ),
                Text(
                  widget.edition,
                  style: TextStyle(fontSize: 20),
                ),
                SizedBox(
                  height: 30,
                ),
                // Text(
                //   co.toString(),
                //   style: TextStyle(fontSize: 20),
                // ),
                // SizedBox(
                //   height: 200,
                // ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    GestureDetector(
                        onTap: () async {
                          setState(() {
                            isLooping = !isLooping;
                          });
                          if (isLooping) {
                            await _player.setLoopMode(LoopMode.one);
                          } else {
                            await _player.setLoopMode(LoopMode.all);
                          }
                        },
                        child: Icon(
                          isLooping ? Icons.repeat_one : Icons.repeat,
                          color: isLooping ? Colors.green : Colors.black,
                        )),
                    GestureDetector(
                      onTap: () async {
                        await _player.seek(Duration.zero,
                            index: _player.effectiveIndices!.first);
                        await _player.play();
                      },
                      child: Icon(Icons.replay_sharp),
                    ),
                  ],
                ),
                SizedBox(
                  height: 20,
                ),
                StreamBuilder<PositionData>(
                  stream: _positionDataStream,
                  builder: (context, snapshot) {
                    final positionData = snapshot.data;
                    format(Duration d) =>
                        d.toString().split('.').first.padLeft(8, "0");
                    final d1 = Duration(hours: 0, minutes: 0, seconds: 0);
                    return Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Text(
                              format(positionData?.position ?? d1),
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            SizedBox(
                              width: 90,
                            ),
                            Text(
                              format(positionData?.duration ?? d1),
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                          ],
                        ),
                        SeekBar(
                          duration: positionData?.duration ?? Duration.zero,
                          position: positionData?.position ?? Duration.zero,
                          bufferedPosition:
                              positionData?.bufferedPosition ?? Duration.zero,
                          onChangeEnd: _player.seek,
                        ),
                      ],
                    );
                  },
                ),
                SizedBox(
                  height: 10,
                ),
                SizedBox(
                  height: 65,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      StreamBuilder<SequenceState?>(
                        stream: _player.sequenceStateStream,
                        builder: (context, snapshot) => IconButton(
                          icon: const Icon(
                            Icons.skip_previous,
                            size: 40,
                          ),
                          onPressed: _player.hasPrevious
                              ? _player.seekToPrevious
                              : null,
                        ),
                      ),
                      SizedBox(
                        width: 50,
                      ),
                      StreamBuilder<PlayerState>(
                        stream: _player.playerStateStream,
                        builder: (context, snapshot) {
                          final playerState = snapshot.data;
                          final processingState = playerState?.processingState;
                          final playing = playerState?.playing;
                          if (processingState == ProcessingState.loading ||
                              processingState == ProcessingState.buffering) {
                            return Container(
                              margin: const EdgeInsets.all(8.0),
                              width: 60.0,
                              height: 60.0,
                              child: const CircularProgressIndicator.adaptive(),
                            );
                          } else if (playing != true) {
                            return IconButton(
                              icon: const Icon(Icons.play_arrow),
                              iconSize: 64.0,
                              onPressed: _player.play,
                            );
                          } else if (processingState !=
                              ProcessingState.completed) {
                            return IconButton(
                              icon: const Icon(Icons.pause),
                              iconSize: 64.0,
                              onPressed: _player.pause,
                            );
                          } else {
                            return IconButton(
                              icon: const Icon(Icons.replay),
                              iconSize: 64.0,
                              onPressed: () => _player.seek(Duration.zero,
                                  index: _player.effectiveIndices!.first),
                            );
                          }
                        },
                      ),
                      SizedBox(
                        width: 50,
                      ),
                      StreamBuilder<SequenceState?>(
                        stream: _player.sequenceStateStream,
                        builder: (context, snapshot) => IconButton(
                          icon: const Icon(
                            Icons.skip_next,
                            size: 40,
                          ),
                          onPressed:
                              _player.hasNext ? _player.seekToNext : null,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 40,
                ),
              ],
            ),
          ),
        ));
  }

  @override
  void dispose() {
    _player.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return OfflineBuilder(
      connectivityBuilder: (
        BuildContext context,
        ConnectivityResult connectivity,
        Widget child,
      ) {
        final bool connected = connectivity != ConnectivityResult.none;

        if (connected) {
          return buildPlayer();
        } else {
          return Center(
            child: Image.asset('assets/images/offline.jpg'),
          );
        }
      },
      child: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
