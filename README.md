# Nyan Cat

A demo for https://twitter.com/hashtag/FlutterCounterChallenge2020?src=hashtag_click

## Demo

Live demo: https://agondev.github.io/flutter_nyancat/

<details>
<summary>Click for gif</summary>
  
![gif with no sound](https://github.com/agondev/flutter_nyancat/blob/master/demo/ex.gif)
</details>

For demo with sound: https://twitter.com/noga_dev/status/1341815264577466369

### Explanation

When the app is first opened it loads the futures containing the audio and the individual frames of the cat.

Then the home page loads with the assets ready and initializes a random viewport with random stars/sparks and counter set to 0.

Pressing the _+_ button spawns a Nyan Cat at a random location off screen and transitions the viewport to a new simulated "camera location" via changing of the variables in the home widget through the incrementCounter function.

The function, in addition to incrementing the actual counter in the middle of the screen, reinitializes the viewport, giving the impression that we're following Nyan Cat in its adventure through space.

#### Notes

N.B. The code is unoptimised.
