import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';


class BndBox extends StatefulWidget {
  final List<dynamic> results;
  final int previewH;
  final int previewW;
  final double screenH;
  final double screenW;
  final String customModel;

  BndBox({
    this.results,
    this.previewH,
    this.previewW,
    this.screenH,
    this.screenW,
    this.customModel,
  });

  @override
  _BndBoxState createState() => _BndBoxState();

}

class _BndBoxState extends State<BndBox> {

  List<dynamic> _inputArr = [];
  int _counter = 0;
  bool flag = false;

  void resetCounter() {
    setState(() {
      _counter = 0;
    });
  }

  void incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  Future<void> _getPrediction(List<double> poses) async {
    if (poses != null) {
      if (poses.elementAt(1) > 500 && poses.elementAt(3) > 500) {
        flag = true;
      }

      if (flag) {
        double range = 300;
        bool left_height_diff = poses.elementAt(1) < range;
        bool right_height_diff = poses.elementAt(3) < range;

        if (left_height_diff && right_height_diff) {
          _counter++;
          flag = false;
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> _renderKeypoints() {
      var lists = <Widget>[];
      widget.results.forEach((re) {
        var list = re["keypoints"].values.map<Widget>((k) {
          var _x = k["x"];
          var _y = k["y"];
          var scaleW, scaleH, x, y;

          if (widget.screenH / widget.screenW > widget.previewH / widget.previewW) {
            scaleW = widget.screenH / widget.previewH * widget.previewW;
            scaleH = widget.screenH;
            var difW = (scaleW - widget.screenW) / scaleW;
            x = (_x - difW / 2) * scaleW;
            y = _y * scaleH;
          } else {
            scaleH = widget.screenW / widget.previewW * widget.previewH;
            scaleW = widget.screenW;
            var difH = (scaleH - widget.screenH) / scaleH;
            x = _x * scaleW;
            y = (_y - difH / 2) * scaleH;
          }
          if (k["part"] == 'rightShoulder' || k["part"] == 'leftShoulder') {
            _inputArr.add(x);
            _inputArr.add(y);
          }

          // To solve mirror problem on front camera
          if (x > 320) {
            var temp = x - 320;
            x = 320 - temp;
          } else {
            var temp = 320 - x;
            x = 320 + temp;
          }
          return Positioned(
            left: x - 275,
            top: y - 50,
            width: 100,
            height: 15,
            child: Container(
              child: Text(
                "● ${k["part"]}",
                style: TextStyle(
                  color: Color.fromRGBO(37, 213, 253, 1.0),
                  fontSize: 12.0,
                ),
              ),
            ),
          );
        }).toList();

        _getPrediction(_inputArr.cast<double>().toList());

        _inputArr.clear();

        lists..addAll(list);
      });
      return lists;
    }

    return Stack(children: <Widget>[
      Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Align(
            alignment: Alignment.bottomCenter,
//            child: LinearPercentIndicator(
//              animation: true,
//              lineHeight: 20.0,
//              animationDuration: 500,
//              animateFromLastPercent: true,
//              percent: _counter,
//              center: Text("${(_counter).toStringAsFixed(1)}"),
//              linearStrokeCap: LinearStrokeCap.roundAll,
//              progressColor: Colors.green,
//            ),
            child: Container(
              height: 100,
              width: 100,
              child: FittedBox(
                child: FloatingActionButton(
                  backgroundColor: Colors.red,
                  onPressed: resetCounter,
                  child: Text(
                    '${_counter.toString()}',
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      Stack(
        children: _renderKeypoints(),
      ),
    ]);
  }
}
