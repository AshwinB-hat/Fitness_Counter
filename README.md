# Fitness Counter

<img src="https://github.com/adityaas26/Yoga-Guru/blob/master/screenshots/fitnessCounter.JPG" alt="Home" height="350"/>

**Fitness Counter** is your personalized fitness repetition counter app based on Flutter. It uses posenet, a pre-trained deep learning model, to estimate body poses in real time and Count the choses Excercise Repetitions.

##DEMO SQUAT Counter
[Squat Counter](https://github.com/adityaas26/Yoga-Guru/blob/master/screenshots/demo.gif)

## Getting Started

### Step 1: Clone the project repository
Open terminal and type

```sh
git clone https://github.com/AshwinB-hat/Fitness_Counter.git
```

### Step 2: Run the app
Connect your device or start the emulator and run the following code

```sh
# change directories
cd

# run the app
flutter run
```

## Project Structure

The project structure is quite primitive right now. 

Let's look at the lib folder

<img src="https://github.com/adityaas26/Yoga-Guru/blob/master/screenshots/fitnessCounter-lib.JPG" alt="project structure" height="400"/>

Don't worry, we'll take a brief look at all the files in a minute! Let's start with **main.dart**

### 1. main.dart
**main.dart** loads data from shared preferences and the camera module. It also defines routes for **home** page.

### 2. home.dart
**home.dart** defines a *Home* class, which is a stateless widget. It contains buttons which routes the user to **poses.dart** according to the button they press. Each button (Single Option for now) call a method *_onPoseSelect()*.

This *_onPoseSelect()* method is quite important as the arguments given to this function decides which list of poses needs to be shown on the poses page.

<br /><br /><br />

### 3. poses.dart
**poses.dart** defines a *Poses* class, which is a stateless widget. It shows a list of available poses as [swipable cards](https://pub.dev/packages/flutter_swiper). The code of the custom cards can be found in **yoga_card.dart** file. Each card is clickable and calls the *_onSelect()* method which directs the user to the InferencePage (**inference.dart**).

<br /><br /><br /><br /><br />

### 4. inference.dart
**inference.dart** defines a *InferencePage* class, which is a stateful widget. It is the class which loads the posenet model. It initializes the Camera object with the camera instance and *_setRecognitions()* callback function. The *_setRecognitions()* method is responsibe for saving the predicted output of the PoseNet model into a List (*_recognitions*). This list of predicted values (*_recognitions*) is then passed to **BndBox's** constructor.

You can read more about the implementation [here](https://github.com/shaqian/flutter_tflite#posenet).

<br /><br />

### 5. camera.dart
**camera.dart** defines a *Camera* class, which is a stateful widget. It contains code related to camera initialization and calls *Tflite.runPoseNetOnFrame()* method by passing in the current *CameraImage* as an argument. The output (predictions) of this method is given as an argument to the *_setRecognitions()* method, which was passed to Camera() as callback.

### 6. bndbox.dart
**bndbox.dart** defines a *BndBox* class, which is a stateless widget. It takes the List of predictions (*_recognitions*) and plot keypoints on the screen. It also prints the accuracy of the model in %.

It also contains the logic of the Application Counter which counts the Repetitions.

<br /><br /><br /><br /><br /><br />

### Co-Contributor.
 - The UI and the Skeleton Is taken from  [Yoga Guru](https://github.com/BetaPundit/Yoga-Guru) built by the talented [Aditya Sharma](https://github.com/BetaPundit).