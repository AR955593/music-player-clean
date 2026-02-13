import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:tunesync/service/audio_controller.dart';
import 'package:tunesync/utils/custom_text_style.dart';
import 'package:tunesync/widgets/bottom_player.dart';
import 'package:tunesync/widgets/neo_button.dart';
import 'package:tunesync/widgets/song_list_item.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final audioController = AudioController();
  bool _hasPermission = false;

  @override
  void initState() {
    super.initState();
    _checkAndRequestPermission();
  }

  /// check audio permission
  Future<void> _checkAndRequestPermission() async {
    final permission = await Permission.audio.status;
    if (permission.isGranted) {
      setState(() => _hasPermission = true);
      await audioController.loadSongs();
    } else {
      final result = await Permission.audio.request();
      setState(() => _hasPermission = result.isGranted);
      if (result.isGranted) {
        await audioController.loadSongs();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: RichText(
          text: TextSpan(
            children: [
              WidgetSpan(
                child: Text(
                  "AR",
                  style: myTextStyle24(
                    fontWeight: FontWeight.bold,
                    fontColor: const Color.fromARGB(255, 53, 53, 53),
                  ),
                ),
              ),
              WidgetSpan(
                child: Text(
                  "Song",
                  style: myTextStyle24(
                    fontWeight: FontWeight.w900,
                    fontColor: const Color.fromARGB(255, 78, 213, 223),
                  ),
                ),
              ),
            ],
          ),
        ),
        leading: Padding(
          padding: const EdgeInsets.all(4.0),
          child: NeoButton(
            child: Center(child: Icon(Icons.person)),
            onPressed: () {},
          ),
        ),
        toolbarHeight: 80,
        actions: [
          NeoButton(child: Icon(Icons.favorite_border), onPressed: () {}),
          SizedBox(width: 16),
          NeoButton(child: Icon(Icons.settings), onPressed: () {}),
          SizedBox(width: 12),
        ],
      ),

      body: ValueListenableBuilder(
        valueListenable: audioController.songs,
        builder: (context, songs, child) {
          // If permission hasn't been granted yet, show a permission prompt
          if (!_hasPermission) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.lock, size: 48, color: Colors.grey),
                  const SizedBox(height: 12),
                  Text(
                    'Storage / Media permission required',
                    style: myTextStyle15(),
                  ),
                  const SizedBox(height: 12),
                  NeoButton(
                    child: const Text('Grant Permission'),
                    onPressed: () async {
                      final result = await Permission.audio.request();
                      setState(() => _hasPermission = result.isGranted);
                      if (result.isGranted) await audioController.loadSongs();
                    },
                  ),
                ],
              ),
            );
          }

          // If permission granted but no songs found, show a friendly message
          if (songs.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.music_note, size: 48, color: Colors.grey),
                  const SizedBox(height: 12),
                  Text('No songs found on this device', style: myTextStyle15()),
                  const SizedBox(height: 12),
                  NeoButton(
                    child: const Text('Refresh'),
                    onPressed: () async {
                      await audioController.loadSongs();
                    },
                  ),
                ],
              ),
            );
          }
          return ListView.builder(
            itemCount: songs.length,
            itemBuilder: (context, index) {
              return SongListItem(song: songs[index], index: index);
            },
          );
        },
      ),
      bottomSheet: BottomPlayer(),
    );
  }
}
