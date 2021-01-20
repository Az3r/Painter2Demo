import 'package:flutter/material.dart';
import 'package:painter2/painter2.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:intl/intl.dart' show DateFormat;

class DrawingPage extends StatefulWidget {
  @override
  _DrawingPageState createState() => _DrawingPageState();
}

class _DrawingPageState extends State<DrawingPage> {
  ImagePicker _imagePicker;
  PainterController _painter;

  @override
  void initState() {
    super.initState();
    _imagePicker = ImagePicker();
    _painter = PainterController()
      ..thickness = 1.0
      ..drawColor = Colors.white
      ..backgroundColor = Colors.black;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('🖌 Drawing ️🖌️🖌️'),
        actions: [
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: _painter.clear,
            tooltip: 'Clear all',
          ),
          IconButton(
            tooltip: 'Change background image',
            icon: Icon(Icons.image),
            onPressed: _changeBackgroundImage,
          ),
          IconButton(
            icon: Icon(Icons.save),
            onPressed: _exportCanvas,
            tooltip: 'Export canvas',
          ),
        ],
      ),
      body: Painter(_painter),
      bottomNavigationBar: ButtonBar(
        alignment: MainAxisAlignment.spaceAround,
        children: [
          IconButton(
            tooltip: 'Undo current work',
            icon: Icon(Icons.undo),
            onPressed: _painter.undo,
          ),
          IconButton(
            tooltip: 'Redo preivous work',
            icon: Icon(Icons.redo),
            onPressed: _painter.redo,
          ),
          PopupMenuButton(
              offset: Offset(0.0, -64.0),
              child: Icon(Icons.border_color),
              itemBuilder: (context) => [
                    PopupMenuItem(
                      enabled: false,
                      child: ThicknessSlider(
                          initialValue: _painter.thickness,
                          onChanged: (value) => _painter.thickness = value),
                    ),
                  ]),
          IconButton(
            tooltip: 'Change background color',
            icon: Icon(Icons.format_paint),
            onPressed: _pickBackgroundColor,
          ),
          IconButton(
            tooltip: 'Change brush color',
            icon: Icon(Icons.brush),
            onPressed: _pickBrushColor,
          ),
        ],
      ),
    );
  }

  void _changeBackgroundImage() async {
    final pickedFile = await _imagePicker.getImage(source: ImageSource.gallery);
    if (pickedFile == null) return;
    final data = await pickedFile.readAsBytes();
    setState(() => _painter.backgroundImage = Image.memory(data));
  }

  void _pickBrushColor() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          titlePadding: const EdgeInsets.all(0.0),
          contentPadding: const EdgeInsets.all(0.0),
          content: SingleChildScrollView(
            child: ColorPicker(
              pickerColor: _painter.drawColor,
              onColorChanged: (color) => _painter.drawColor = color,
              colorPickerWidth: 300.0,
              pickerAreaHeightPercent: 0.7,
              enableAlpha: true,
              displayThumbColor: true,
              showLabel: true,
              paletteType: PaletteType.hsv,
              pickerAreaBorderRadius: const BorderRadius.only(
                topLeft: const Radius.circular(2.0),
                topRight: const Radius.circular(2.0),
              ),
            ),
          ),
        );
      },
    );
  }

  void _pickBackgroundColor() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Select a color'),
          content: SingleChildScrollView(
            child: BlockPicker(
                pickerColor: _painter.backgroundColor,
                onColorChanged: (color) => _painter.backgroundColor = color),
          ),
        );
      },
    );
  }

  void _exportCanvas() async {
    final name = await showDialog<String>(
      context: context,
      builder: (context) => ImageNameTextField(),
    );
    if (name == null || name.isEmpty) return;
    final data = await _painter.exportAsPNGBytes();
    final result = await ImageGallerySaver.saveImage(data, name: name);
    print(result);
    print(await Permission.photos.status);
  }

  @override
  void dispose() {
    _painter.dispose();
    super.dispose();
  }
}

class ImageNameTextField extends StatefulWidget {
  @override
  _ImageNameTextFieldState createState() => _ImageNameTextFieldState();
}

class _ImageNameTextFieldState extends State<ImageNameTextField> {
  TextEditingController _textEditor;
  @override
  void initState() {
    super.initState();
    final name = DateFormat('yyyy-MM-dd-HH-mm-ss').format(DateTime.now());
    _textEditor = TextEditingController(text: name);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Save image'),
      content: TextField(controller: _textEditor),
      actions: [
        TextButton(
          child: Text('Cancel'),
          onPressed: Navigator.of(context).pop,
        ),
        TextButton(
          child: Text('Confirm'),
          onPressed: () => Navigator.of(context).pop(_textEditor.text),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _textEditor.dispose();
    super.dispose();
  }
}

class ThicknessSlider extends StatefulWidget {
  final double initialValue;
  final void Function(double onChanged) onChanged;

  const ThicknessSlider({
    Key key,
    this.initialValue = 1.0,
    this.onChanged,
  }) : super(key: key);

  @override
  _ThicknessSliderState createState() => _ThicknessSliderState();
}

class _ThicknessSliderState extends State<ThicknessSlider> {
  TextEditingController _controller;
  double _thickness;
  @override
  void initState() {
    super.initState();
    _controller =
        TextEditingController(text: widget.initialValue.toStringAsFixed(0));
    _thickness = widget.initialValue;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Slider(
          label: _thickness.toStringAsFixed(0),
          onChanged: (value) {
            _controller.text = value.toStringAsFixed(0);
            widget?.onChanged(value);
            setState(() => _thickness = value);
          },
          value: _thickness,
          min: 1.0,
          max: 50.0,
        ),
        SizedBox(
            width: 32,
            child: TextField(
              textInputAction: TextInputAction.done,
              keyboardType: TextInputType.number,
              controller: _controller,
              onTap: () => _controller.selection = TextSelection(
                baseOffset: 0,
                extentOffset: _controller.text.length,
              ),
              onSubmitted: (text) {
                final value =
                    double.tryParse(text)?.clamp(1.0, 100) ?? _thickness;
                _controller.text = value.toStringAsFixed(0);
                setState(() => _thickness = value);
              },
              decoration: InputDecoration(
                labelStyle: TextStyle(fontSize: 16),
                border: InputBorder.none,
                focusedBorder: InputBorder.none,
                enabledBorder: InputBorder.none,
                errorBorder: InputBorder.none,
                disabledBorder: InputBorder.none,
                contentPadding: EdgeInsets.zero,
              ),
            )),
      ],
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
