import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_2d_grid/2d_grid.dart';
import 'package:flutter_2d_grid/algorithms.dart';
import 'package:flutter_2d_grid/animated_button_popup.dart';
import 'package:flutter_2d_grid/fab_with_popup.dart';
import 'package:flutter_2d_grid/generation_algorithms.dart';
import 'package:provider/provider.dart';
import 'package:flutter_2d_grid/colors.dart';

class Visualizer extends StatefulWidget {
  @override
  _VisualizerState createState() => _VisualizerState();
}

class _VisualizerState extends State<Visualizer> {
  bool isRunning = false;

  int _selectedButton = 1;
  bool _generationRunning = false;

  void setActiveButton(int i, BuildContext context) {
    switch (i) {
      case 1: //brush
        grid.isPanning = false;
        drawTool = true;
        setState(() {
          _selectedButton = 1;
        });
        break;
      case 2: //eraser
        grid.isPanning = false;
        drawTool = false;
        setState(() {
          _selectedButton = 2;
        });
        break;
      case 3: // pan
        grid.isPanning = true;
        setState(() {
          _selectedButton = 3;
        });
        break;
      default:
    }
  }

  void disableBottomButtons() {
    setState(() {
      _disabled1 = true;
      _disabled2 = true;
      _disabled3 = true;
      _disabled4 = true;
      _disabled5 = true;
      _disabled6 = true;
    });
  }

  void enableBottomButtons() {
    setState(() {
      _disabled1 = false;
      _disabled2 = false;
      _disabled3 = false;
      _disabled4 = false;
      _disabled5 = false;
      _disabled6 = false;
    });
  }

  Color _color6 = Colors.deepPurple;

  bool _disabled1 = false;
  bool _disabled2 = false;
  bool _disabled3 = false;
  bool _disabled4 = false;
  bool _disabled5 = false;
  bool _disabled6 = false;

  bool drawTool = true;

  Grid grid = Grid(41, 68, 50, 10, 10, 35, 50);

  double brushSize = 0.1;

  @override
  initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var popupmodel = Provider.of<PopUpModel>(context, listen: false);
    var operationModel =
        Provider.of<OperationCountModel>(context, listen: false);
    final snackBar = SnackBar(
      content: Text("Couldn't find path."),
      duration: Duration(milliseconds: 1400),
    );
    return SafeArea(
      child: Scaffold(
        backgroundColor: backgroundColor,
        floatingActionButton: Consumer<PopUpModel>(
          builder: (_, model, __) {
            return FabWithPopUp(
              disabled: _disabled6,
              color: _color6,
              width: 150,
              direction: AnimatedButtonPopUpDirection.vertical,
              child: RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  text: "Visualize",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      height: 1.0,
                      fontWeight: FontWeight.bold),
                  // children: [
                  //   TextSpan(
                  //       style: TextStyle(
                  //         color: Colors.white,
                  //         fontSize: 16,
                  //       ),
                  //       text: (() {
                  //         switch (model.selectedPathAlg) {
                  //           case VisualizerAlgorithm.astar:
                  //             return "A*";
                  //             break;
                  //           case VisualizerAlgorithm.dijkstra:
                  //             return "Dijkstra";
                  //             break;
                  //           case VisualizerAlgorithm.bidir_dijkstra:
                  //             return "Bidir   Dijkstra";
                  //             break;
                  //           default:
                  //             return "Maze";
                  //         }
                  //       }()))
                  // ]
                ),
              ),
              onPressed: () {
                model.stop = false;
                setActiveButton(3, context);
                setState(() {
                  isRunning = true;
                  _color6 = Colors.redAccent;
                });
                disableBottomButtons();
                grid.clearPaths();
                PathfindAlgorithms.visualize(
                    algorithm: model.selectedPathAlg,
                    gridd: grid.nodeTypes,
                    startti: grid.starti,
                    starttj: grid.startj,
                    finishi: grid.finishi,
                    finishj: grid.finishj,
                    onShowClosedNode: (int i, int j) {
                      grid.addNode(i, j, Brush.closed);
                    },
                    onShowOpenNode: (int i, int j) {
                      grid.addNode(i, j, Brush.open);
                    },
                    speed: () {
                      return model.speed;
                    },
                    onDrawPath: (Node lastNode, int c) {
                      operationModel.operations = c;
                      if (model.stop) {
                        setState(() {
                          _color6 = Colors.deepPurple;
                        });
                        enableBottomButtons();
                        return true;
                      }
                      grid.drawPath2(lastNode);
                      return false;
                    },
                    onDrawSecondPath: (Node lastNode, int c) {
                      operationModel.operations = c;
                      if (model.stop) {
                        setState(() {
                          _color6 = Colors.deepPurple;
                        });
                        enableBottomButtons();
                        return true;
                      }
                      grid.drawSecondPath2(lastNode);
                      return false;
                    },
                    onFinished: (pathFound) {
                      setState(() {
                        isRunning = false;
                        _color6 = Colors.deepPurple;
                      });
                      enableBottomButtons();
                      if (!pathFound) {
                        Scaffold.of(context).showSnackBar(snackBar);
                      }
                    });
              },
              items: <AnimatedButtonPopUpItem>[
                AnimatedButtonPopUpItem(
                  child: Text(
                    "A*",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16),
                  ),
                  onPressed: () {
                    model.setActivePAlgorithm(1);
                  },
                ),
                AnimatedButtonPopUpItem(
                  child: Text(
                    "Dijkstra",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16),
                  ),
                  onPressed: () {
                    model.setActivePAlgorithm(2);
                  },
                ),
                AnimatedButtonPopUpItem(
                  child: Text(
                    "Bidirectional Dijkstra",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16),
                  ),
                  onPressed: () {
                    model.setActivePAlgorithm(3);
                  },
                ),
              ],
            );
          },
        ),
        bottomNavigationBar: BottomAppBar(
          color: gridColor,
          child: Padding(
            padding: const EdgeInsets.only(top: 6.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              mainAxisSize: MainAxisSize.max,
              children: <Widget>[
                Consumer<PopUpModel>(
                  builder: (_, model, __) {
                    return AnimatedButtonWithPopUp(
                      width: 130,
                      direction: AnimatedButtonPopUpDirection.vertical,
                      child: RichText(
                        textAlign: TextAlign.center,
                        text: TextSpan(
                            text: "",
                            style: TextStyle(
                                color: Colors.white, fontSize: 22, height: 1.0),
                            children: [
                              TextSpan(
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold),
                                  text: (() {
                                    switch (model.selectedAlg) {
                                      case GridGenerationFunction.backtracker:
                                        return "Backtracker Maze";
                                        break;
                                      case GridGenerationFunction.random:
                                        return "Random     Walls";
                                        break;
                                      case GridGenerationFunction.recursive:
                                        return "Recursive Maze";
                                        break;
                                      default:
                                        return "Maze";
                                    }
                                  }()))
                            ]),
                      ),
                      onPressed: () {
                        model.stop = false;
                        setActiveButton(3, context);
                        setState(() {
                          isRunning = true;
                          _generationRunning = true;
                        });
                        disableBottomButtons();
                        grid.clearPaths();
                        //grid.fillWithWall();
                        GenerateAlgorithms.visualize(
                            algorithm: model.selectedAlg,
                            gridd: grid.nodeTypes,
                            stopCallback: () {
                              return model.stop;
                            },
                            onShowCurrentNode: (i, j) {
                              //grid.addNode(i, j, Brush.open);
                              grid.putCurrentNode(i, j);
                            },
                            onRemoveWall: (i, j) {
                              grid.removeNode(i, j, 1);
                            },
                            onShowWall: (i, j) {
                              grid.addNode(i, j, Brush.wall);
                            },
                            speed: () {
                              return model.speed;
                            },
                            onFinished: () {
                              setState(() {
                                isRunning = false;
                                _generationRunning = false;
                              });
                              enableBottomButtons();
                            });
                      },
                      onLongPressed: () {},
                      disabled: _disabled5,
                      color: _generationRunning
                          ? Colors.redAccent
                          : Theme.of(context).buttonColor,
                      items: <AnimatedButtonPopUpItem>[
                        AnimatedButtonPopUpItem(
                          child: Text("Backtracker Maze",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 16,
                              )),
                          onPressed: () {
                            model.setActiveAlgorithm(1, context);
                          },
                        ),
                        AnimatedButtonPopUpItem(
                          child: Text(
                            "Random       Walls",
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 16),
                          ),
                          onPressed: () {
                            model.setActiveAlgorithm(2, context);
                          },
                        ),
                        AnimatedButtonPopUpItem(
                          child: Text(
                            "Recursive    Maze",
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 16),
                          ),
                          onPressed: () {
                            model.setActiveAlgorithm(3, context);
                          },
                        )
                      ],
                    );
                  },
                ),
                Container(
                  width: 0,
                  height: 60,
                ),
                Consumer<PopUpModel>(
                  builder: (_, model, __) {
                    return AnimatedButtonWithPopUp(
                        direction: AnimatedButtonPopUpDirection.horizontal,
                        child: Icon(
                          Icons.add_circle,
                          size: 28,
                          color: Colors.white,
                        ),
                        onPressed: () {
                          setActiveButton(1, context);
                        },
                        onLongPressed: () {
                          setActiveButton(1, context);
                        },
                        disabled: _disabled1,
                        color: _selectedButton == 1
                            ? Colors.redAccent
                            : Theme.of(context).buttonColor,
                        items: <AnimatedButtonPopUpItem>[
                          AnimatedButtonPopUpItem(
                            child: Icon(
                              Icons.crop_square,
                              size: 28,
                              color: Colors.white,
                            ),
                            onPressed: () {
                              model.setActiveBrush(1);
                            },
                          ),
                          AnimatedButtonPopUpItem(
                            child: Icon(
                              Icons.location_on,
                              size: 28,
                              color: Colors.white,
                            ),
                            onPressed: () {
                              model.setActiveBrush(2);
                            },
                          ),
                          AnimatedButtonPopUpItem(
                            child: Icon(
                              Icons.gps_fixed,
                              size: 28,
                              color: Colors.white,
                            ),
                            onPressed: () {
                              model.setActiveBrush(3);
                            },
                          )
                        ]);
                  },
                ),
                Container(
                  width: 0,
                  height: 60,
                ),
                AnimatedButtonWithPopUp(
                  child: Icon(
                    Icons.remove_circle,
                    size: 28,
                    color: Colors.white,
                  ),
                  onPressed: () {
                    setActiveButton(2, context);
                  },
                  disabled: _disabled2,
                  color: _selectedButton == 2
                      ? Colors.redAccent
                      : Theme.of(context).buttonColor,
                ),
                Container(
                  width: 0,
                  height: 60,
                ),
                AnimatedButtonWithPopUp(
                  child: Icon(
                    Icons.delete,
                    size: 28,
                    color: Colors.white,
                  ),
                  color: Theme.of(context).buttonColor,
                  disabled: _disabled4,
                  onPressed: () {
                    grid.clearBoard(onFinished: () {});
                  },
                ),
              ],
            ),
          ),
        ),
        body: Stack(
          children: <Widget>[
            Selector<PopUpModel, Brush>(
              selector: (context, model) => model.selectedBrush,
              builder: (_, brush, __) {
                return grid.gridWidget(
                  onTapNode: (i, j) {
                    grid.clearPaths();
                    if (drawTool) {
                      if (brush == Brush.wall) {
                        grid.addNode(i, j, Brush.wall);
                      } else {
                        grid.hoverSpecialNode(i, j, brush);
                      }
                    } else {
                      grid.removeNode(i, j, 1);
                    }
                  },
                  onDragNode: (i, j, k, l, t) {
                    if (drawTool) {
                      if (brush != Brush.wall) {
                        grid.hoverSpecialNode(k, l, brush);
                      } else {
                        grid.addNode(k, l, brush);
                      }
                    } else {
                      grid.removeNode(k, l, 1);
                    }
                  },
                  onDragNodeEnd: () {
                    if (brush != Brush.wall && drawTool) {
                      grid.addSpecialNode(brush);
                    }
                  },
                );
              },
            ),
            AnimatedPositioned(
              left: MediaQuery.of(context).size.width / 2 - 23,
              bottom: isRunning ? 15 : -50,
              duration: Duration(milliseconds: 500),
              curve: Curves.elasticOut,
              child: FloatingActionButton(
                backgroundColor: Colors.red,
                child: Icon(Icons.pause, color: Colors.black),
                mini: true,
                onPressed: () {
                  setState(() {
                    isRunning = false;
                  });
                  popupmodel.stop = true;
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class OperationCountModel extends ChangeNotifier {
  int _operations = 0;

  int get operations => _operations;

  set operations(int value) {
    _operations = value;
    notifyListeners();
  }
}
