import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:yoga_guru/util/pose_data.dart';


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
  Map<String, List<double>> inputArr;
  int _counter;
  FlutterTts flutterTts;
  double lowerRange, upperRange;
  bool midCount,isCorrectPosture;

  void setRangeBasedOnModel(){
    if(widget.customModel == bodyWeight[0]){
      upperRange=300;
      lowerRange=500;
    } else if(widget.customModel == bodyWeight[1]) {
      upperRange = 500;
      lowerRange = 700;
    }
  }
  @override
  void initState() {
    super.initState();
    inputArr=new Map();
    _counter=0;
    midCount=false;
    isCorrectPosture=false;
    setRangeBasedOnModel();
    flutterTts = new FlutterTts();
    flutterTts.speak("Your Workout Has Started");
  }

  void resetCounter() {
    setState(() {
      _counter = 0;
    });
    flutterTts.speak("Your Workout has been Reset");
  }

  void incrementCounter() {
    setState(() {
      _counter++;
    });
    flutterTts.speak(_counter.toString());
  }

  void setMidCount(bool f) {
    //when midcount is activated
    if(f && !midCount) {
      flutterTts.speak("Perfect!");
    }
    setState(() {
      midCount = f;
    });

  }

  Color getCounterColor() {
    if(isCorrectPosture) {
      return Colors.green;
    } else {
      return Colors.red;
    }
  }

  Positioned _createPositionedBlobs(double x, double y) {
    return Positioned(
      height: 5,
      width: 40,
      left:x,
      top:y,
      child: Container(
        color: getCounterColor(),
      ),
    );
  }

  List<Widget> _renderHelperBlobs() {
    List<Widget> listToReturn = <Widget>[];
    listToReturn.add(_createPositionedBlobs(0, upperRange));
    listToReturn.add(_createPositionedBlobs(0, lowerRange));
    return listToReturn;
  }

  //region Core
  bool _postureAccordingToExercise(Map<String, List<double>> poses){
    if(widget.customModel==bodyWeight[1]) {
      return poses['leftShoulder'][1] < upperRange
          && poses['rightShoulder'][1] < upperRange;
    }
    if(widget.customModel==bodyWeight[0]) {
      return poses['leftShoulder'][1] < upperRange
          && poses['rightShoulder'][1] < upperRange
          && poses['rightKnee'][1]>lowerRange
          && poses['leftKnee'][1]>lowerRange;
    }
  }
  _checkCorrectPosture(Map<String, List<double>> poses) {
      if(_postureAccordingToExercise(poses)){
          if(!isCorrectPosture){
            setState(() {
              isCorrectPosture=true;
            });
          }
      } else {
        if(isCorrectPosture) {
          setState(() {
            isCorrectPosture = false;
          });
        }
      }
  }

  Future<void> _countingLogic(Map<String, List<double>> poses) async {
    if (poses != null) {
      //check posture before beginning count
      if (isCorrectPosture && poses['leftShoulder'][1] > upperRange && poses['rightShoulder'][1] > upperRange) {
        setMidCount(true);
      }

      if (midCount && poses['leftShoulder'][1] < upperRange && poses['rightShoulder'][1] < upperRange) {
          incrementCounter();
          setMidCount(false);
        }
      //check the posture when not in midcount
      if(!midCount) {
        _checkCorrectPosture(poses);
      }
    }
  }
  //endregion

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

          inputArr[k['part']] = [x,y];

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
                "●",
                style: TextStyle(
                  color: Color.fromRGBO(37, 213, 253, 1.0),
                  fontSize: 12.0,
                ),
              ),
            ),
          );
        }).toList();

        _countingLogic(inputArr);

        inputArr.clear();
        lists..addAll(list);
      });
      return lists;
    }

    return Stack(children: <Widget>[
      Stack(
       children: _renderHelperBlobs(),
      ),
      Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Align(
            alignment: Alignment.center,
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
            child: Padding(
              padding: EdgeInsets.fromLTRB(0, 0, 0, 10),
            child: Container(
              height: 100,
              width: 100,
              child: FittedBox(
                child: FloatingActionButton(
                  backgroundColor: getCounterColor(),
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
          ),
        ],
      ),
      Stack(
        children: _renderKeypoints(),
      ),
    ]);
  }
}
