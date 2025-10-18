import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:file_saver/file_saver.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' hide Image;
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_drawing_board/main.dart';
import 'package:flutter_drawing_board/src/src.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:universal_html/html.dart' as html;
import 'package:url_launcher/url_launcher.dart';

class CanvasSideBar extends StatefulWidget {
  final ValueNotifier<Color> selectedColor;
  final ValueNotifier<double> strokeSize;
  final ValueNotifier<double> eraserSize;
  final ValueNotifier<DrawingTool> drawingTool;
  final CurrentStrokeValueNotifier currentSketch;
  final ValueNotifier<List<Stroke>> allSketches;
  final GlobalKey canvasGlobalKey;
  final ValueNotifier<bool> filled;
  final ValueNotifier<int> polygonSides;
  final ValueNotifier<ui.Image?> backgroundImage;
  final UndoRedoStack undoRedoStack;
  final ValueNotifier<bool> showGrid;

  const CanvasSideBar({
    super.key,
    required this.selectedColor,
    required this.strokeSize,
    required this.eraserSize,
    required this.drawingTool,
    required this.currentSketch,
    required this.allSketches,
    required this.canvasGlobalKey,
    required this.filled,
    required this.polygonSides,
    required this.backgroundImage,
    required this.undoRedoStack,
    required this.showGrid,
  });

  @override
  State<CanvasSideBar> createState() => _CanvasSideBarState();
}

class _CanvasSideBarState extends State<CanvasSideBar> {
  UndoRedoStack get undoRedoStack => widget.undoRedoStack;
  final ScrollController scrollController = ScrollController();

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 300,
      height: MediaQuery.of(context).size.height < 680 ? 450 : 610,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.horizontal(
          right: Radius.circular(10),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 3,
            offset: const Offset(3, 3),
          ),
        ],
      ),
      child: AnimatedBuilder(
        animation: Listenable.merge([
          widget.selectedColor,
          widget.strokeSize,
          widget.eraserSize,
          widget.drawingTool,
          widget.filled,
          widget.polygonSides,
          widget.backgroundImage,
          widget.showGrid,
        ]),
        builder: (context, _) {
          return Scrollbar(
            controller: scrollController,
            thumbVisibility: true,
            trackVisibility: true,
            child: ListView(
              padding: const EdgeInsets.all(10.0),
              controller: scrollController,
              children: [
                const SizedBox(height: 10),
                const Text(
                  'Shapes',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const Divider(),
                Wrap(
                  spacing: 5,
                  runSpacing: 5,
                  children: [
                    _IconBox(
                      iconData: FontAwesomeIcons.pencil,
                      selected: widget.drawingTool.value == DrawingTool.pencil,
                      onTap: () => widget.drawingTool.value = DrawingTool.pencil,
                      tooltip: 'Pencil',
                    ),
                    _IconBox(
                      selected: widget.drawingTool.value == DrawingTool.line,
                      onTap: () => widget.drawingTool.value = DrawingTool.line,
                      tooltip: 'Line',
                      child: Container(
                        width: 22,
                        height: 2,
                        color: widget.drawingTool.value == DrawingTool.line
                            ? Colors.grey[900]
                            : Colors.grey,
                      ),
                    ),
                    _IconBox(
                      iconData: Icons.hexagon_outlined,
                      selected: widget.drawingTool.value == DrawingTool.polygon,
                      onTap: () => widget.drawingTool.value = DrawingTool.polygon,
                      tooltip: 'Polygon',
                    ),
                    _IconBox(
                      iconData: FontAwesomeIcons.eraser,
                      selected: widget.drawingTool.value == DrawingTool.eraser,
                      onTap: () => widget.drawingTool.value = DrawingTool.eraser,
                      tooltip: 'Eraser',
                    ),
                    _IconBox(
                      iconData: FontAwesomeIcons.square,
                      selected: widget.drawingTool.value == DrawingTool.square,
                      onTap: () => widget.drawingTool.value = DrawingTool.square,
                      tooltip: 'Square',
                    ),
                    _IconBox(
                      iconData: FontAwesomeIcons.circle,
                      selected: widget.drawingTool.value == DrawingTool.circle,
                      onTap: () => widget.drawingTool.value = DrawingTool.circle,
                      tooltip: 'Circle',
                    ),
                    _IconBox(
                      iconData: FontAwesomeIcons.ruler,
                      selected: widget.showGrid.value,
                      onTap: () => widget.showGrid.value = !widget.showGrid.value,
                      tooltip: 'Guide Lines',
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Text(
                      'Fill Shape: ',
                      style: TextStyle(fontSize: 12),
                    ),
                    Checkbox(
                      value: widget.filled.value,
                      onChanged: (val) => widget.filled.value = val ?? false,
                    ),
                  ],
                ),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 150),
                  child: widget.drawingTool.value == DrawingTool.polygon
                      ? Row(
                          children: [
                            const Text(
                              'Polygon Sides: ',
                              style: TextStyle(fontSize: 12),
                            ),
                            Expanded(
                              child: Slider(
                                value: widget.polygonSides.value.toDouble(),
                                min: 3,
                                max: 8,
                                divisions: 5,
                                label: '${widget.polygonSides.value}',
                                onChanged: (val) =>
                                    widget.polygonSides.value = val.toInt(),
                              ),
                            ),
                          ],
                        )
                      : const SizedBox.shrink(),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Colors',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const Divider(),
                ColorPalette(selectedColorListenable: widget.selectedColor),
                const SizedBox(height: 20),
                const Text(
                  'Size',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const Divider(),
                _buildSlider('Stroke Size: ', widget.strokeSize, 1, 50),
                _buildSlider('Eraser Size: ', widget.eraserSize, 1, 80),
                const SizedBox(height: 20),
                const Text(
                  'Actions',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const Divider(),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    TextButton(
                      onPressed: widget.allSketches.value.isNotEmpty
                          ? undoRedoStack.undo
                          : null,
                      child: const Text('Undo'),
                    ),
                    ValueListenableBuilder<bool>(
                      valueListenable: undoRedoStack.canRedo,
                      builder: (_, canRedo, __) => TextButton(
                        onPressed: canRedo ? undoRedoStack.redo : null,
                        child: const Text('Redo'),
                      ),
                    ),
                    TextButton(
                      onPressed: undoRedoStack.clear,
                      child: const Text('Clear'),
                    ),
                    TextButton(
                      onPressed: () async {
                        if (widget.backgroundImage.value != null) {
                          widget.backgroundImage.value = null;
                        } else {
                          final image = await _getImage();
                          if (image != null) {
                            widget.backgroundImage.value = image;
                          }
                        }
                      },
                      child: Text(
                        widget.backgroundImage.value == null
                            ? 'Add Background'
                            : 'Remove Background',
                      ),
                    ),
                    TextButton(
                      onPressed: () => _launchUrl(kGithubRepo),
                      child: const Text('Fork on Github'),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                const Text(
                  'Export',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const Divider(),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _exportButton('Export PNG', 'png'),
                    _exportButton('Export JPEG', 'jpeg'),
                  ],
                ),
                const Divider(),
                Center(
                  child: GestureDetector(
                    onTap: () => _launchUrl('https://github.com/JideGuru'),
                    child: const Text(
                      'Made BY  GANESH',
                      style: TextStyle(fontSize: 12),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSlider(
    String label,
    ValueNotifier<double> valueNotifier,
    double min,
    double max,
  ) {
    return Row(
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 12),
        ),
        Expanded(
          child: Slider(
            value: valueNotifier.value,
            min: min,
            max: max,
            onChanged: (val) => valueNotifier.value = val,
          ),
        ),
      ],
    );
  }

  Widget _exportButton(String label, String ext) {
    return SizedBox(
      width: 140,
      child: TextButton(
        onPressed: () async {
          final bytes = await getBytes();
          if (bytes != null) {
            await saveFile(bytes, ext);
          } else {
            _showErrorSnackBar('Failed to export image');
          }
        },
        child: Text(label),
      ),
    );
  }

  Future<void> saveFile(Uint8List bytes, String extension) async {
    try {
      if (kIsWeb) {
        final blobUrl = Uri.dataFromBytes(
          bytes,
          mimeType: 'image/$extension',
        ).toString();
        html.AnchorElement(href: blobUrl)
          ..download =
              'FlutterLetsDraw-${DateTime.now().toIso8601String()}.$extension'
          ..click();
      } else {
        await FileSaver.instance.saveFile(
          name: 'FlutterLetsDraw-${DateTime.now().toIso8601String()}',
          bytes: bytes,
          mimeType: extension == 'png' ? MimeType.png : MimeType.jpeg,
        );
      }
      _showSuccessSnackBar('Image exported successfully!');
    } catch (e) {
      _showErrorSnackBar('Failed to export image: $e');
    }
  }

  Future<ui.Image?> _getImage() async {
    try {
      if (kIsWeb) {
        final picker = ImagePicker();
        final image = await picker.pickImage(source: ImageSource.gallery);
        if (image != null) {
          final bytes = await image.readAsBytes();
          return await decodeImageFromList(bytes);
        }
      } else if (Platform.isAndroid || Platform.isIOS) {
        final image = await ImagePicker().pickImage(source: ImageSource.gallery);
        if (image != null) {
          final bytes = await image.readAsBytes();
          return await decodeImageFromList(bytes);
        }
      } else {
        final result = await FilePicker.platform.pickFiles(
          type: FileType.image,
        );
        if (result != null && result.files.isNotEmpty) {
          final path = result.files.single.path;
          if (path != null) {
            final bytes = await File(path).readAsBytes();
            return await decodeImageFromList(bytes);
          }
        }
      }
    } catch (e) {
      _showErrorSnackBar('Failed to load image: $e');
    }
    return null;
  }

  Future<void> _launchUrl(String url) async {
    try {
      final uri = Uri.parse(url);
      if (kIsWeb) {
        html.window.open(url, '_blank');
      } else if (!await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      )) {
        throw 'Could not launch $url';
      }
    } catch (e) {
      _showErrorSnackBar('Failed to launch URL: $e');
    }
  }

  Future<Uint8List?> getBytes() async {
    try {
      final boundary = widget.canvasGlobalKey.currentContext?.findRenderObject()
          as RenderRepaintBoundary?;
      if (boundary == null) return null;
      final image = await boundary.toImage();
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      return byteData?.buffer.asUint8List();
    } catch (e) {
      if (kDebugMode) {
        print('Error getting bytes: $e');
      }
      return null;
    }
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }
}

class _IconBox extends StatelessWidget {
  final IconData? iconData;
  final Widget? child;
  final bool selected;
  final VoidCallback onTap;
  final String? tooltip;

  const _IconBox({
    super.key,
    this.iconData,
    this.child,
    this.tooltip,
    required this.selected,
    required this.onTap,
  }) : assert(child != null || iconData != null);

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 35,
          width: 35,
          decoration: BoxDecoration(
            border: Border.all(
              color: selected ? Colors.grey[900]! : Colors.grey,
              width: 1.5,
            ),
            borderRadius: const BorderRadius.all(Radius.circular(5)),
          ),
          child: Tooltip(
            message: tooltip ?? '',
            preferBelow: false,
            child: child ??
                Icon(
                  iconData,
                  color: selected ? Colors.grey[900] : Colors.grey,
                  size: 20,
                ),
          ),
        ),
      ),
    );
  }
}