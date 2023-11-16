# RedWire
A simple top to down application to play around with circuits inspired on the Redstone system in Minecraft

## Nagivating the app

### General controls
 - **Zoom:** Scroll up and down to zoom in and out
 - **Move:** Press the scroll wheel to move around
 - **Draw:** On the grid, if you press left click and drag the mouse, you will draw your currently selected component
 - **Interact:** When pressing right click on top of a component, you will change its state (if aplicable)
 - **Erase:** Pressing E will toggle eraser mode, allowing you to remove components
 - **Hide Drawer:** Pressing space will automatically hide or show the drawer with the components
 - **Vertical snap:** Holding V will snap the pointer to the vertical axis, allowing you to draw stright horizontal lines
 - **Horizontal snap:** Holding H will snap the pointer to the horizontal axis, allowing you to draw straight vertical lines


![Screenshot 2023-11-01 144416](https://github.com/AsperTheDog/WireBug/assets/45227294/eb64a21e-94a8-40db-8a64-6cfcda2307fb)

### Projects
At the very top the file menu can be seen, this allows you to control which project you are currently working on by loading, saving or creating projects. 
A project is a file containing the data of your circuit. This includes what components will be present in which positions, rotations and states. **The system will not save the power state of a system**

### General options
Right below the top bar you will find an overlayed bar with different options:
- The background color picker is self-explanatory
- The wire color picker will let you choose how the cables will be displayed when powered. It is recommended to set it to a bright color different than the background color.
- The TPS input will let you change how fast the simulation performs, measured in Ticks Per Second (TPS). This determines how long components with delay will wait before updating their outputs
- The eraser symbol lets you change between erase mode and draw mode. This lets you remove components from the grid. The shortcut for this button is **E**
- The Wire Upd. toggle will enable and disable visual updates for wires. They will still work system wise as always, but the changes won't be visible. Use this if your project contains a very big circuits with very frequent updates that visibly slow down the program.
- The overwrite toggle will determine if you will replace current components of the grid when drawing over them. If true, any component in the grid will be replaced by the component of your choice when drawing on that tile, otherwise it will simply not draw anything.

All settings except eraser mode will be saved to your project

### Drawer
The drawer is the big section to the right of the screen and contains the components you can place on the grid. It can be hidden by pressing the vertical black bar to the left of the drawer, or by pressing **space**.
When clicking on a component, you will select it. Once you then click and drag on the grid the selected component will be drawn on to the grid.

## How it works

Everything in the system is based around power levels: There are 15 different intensity levels that are represented by the brightness of the powered areas in each component.
Each component will react in different ways to changes in either other components (fluctuations in their output intensity) or their internal state (interactions by the user).

There are 9 types of components:

### Wire
This component is completely passive. It will simply transmit the strongest intensity going inwards towards all other elements around it. Every time any amount of power intensity enters the cable it will be reduced by one level.
Wires cannot be prevented from sticking to other elements around it.  
<img src='https://github.com/AsperTheDog/WireBug/assets/45227294/ac00c599-8951-465d-a829-5a43f3166971' width='300'>

### Repeater
This component has one signal input and one output. When the input receives a signal intensity greater than zero, a repeater will output a signal intensity of 15 after a specific amount of ticks. The amount of ticks can be modified to go from 1 to 4 by interacting with the component. The amount of ticks is reperesented by the yellow lines on the side.  
<img src='https://github.com/AsperTheDog/WireBug/assets/45227294/3057d14b-b7c6-4ea5-9e93-40af9c31546f' width='300'>

### Comparator
This component has three inputs and one output. A comparator differentiates its inputs to the side (side input) from the one directly behind it (back input). The output of the comparator will have to different behaviors depending on its mode, which can be toggled by interacting with it:
 - In comparison mode (yellow light off) the comparator will output a signal if the back input has a greater signal intensity than any of the side inputs. The intensity of the output will be equal to the intensity of the back input: `output = back if (left ≤ back and right ≤ back) else 0`
 - In substraction mode (yellow light on) the comparator will output a signal equal to the back input minus the greatest signal out of the two sides: `output = back - max(0, back - max(right, left))`
The comparator has an unavoidable one tick delay.  
<img src='https://github.com/AsperTheDog/WireBug/assets/45227294/288027d0-21c7-4619-a3e3-180514c66bfa' width='300'>

### Negator
This component has one signal input and one output. When the input receives a signal intensity of zero, a negator will output a signal of 15. If it otherwise receives a signal greater than zero, it will output a signal intensity of zero. The negator has an unmodifiable one tick delay.  
<img src='https://github.com/AsperTheDog/WireBug/assets/45227294/551d392e-08ec-469e-a784-6031a4676a7c' width='300'>

### Generator
This component acts as the user controlled power source. It has an omnidirectional output that will release a signal strength of 15 on demand. It can be turned on or off by interacting with it.  
<img src='https://github.com/AsperTheDog/WireBug/assets/45227294/5d0ff666-0922-4b5b-bdff-74bea3c8bd68' width='300'>

### Crossing
This component acts the same way as a wire but with two independent lines in the vertical and horizontal axis respectively. Power intensities that affect one line will not be affected by the other.  
<img src='https://github.com/AsperTheDog/WireBug/assets/45227294/f01e8d34-5519-44d9-aa58-ea27b87de5c6' width='300'>

### Flicker
This component has one signal input and one output. The flicker will quickly signal a one tick pulse with an intensity of 15 whenever the input signal changes from 0 to more than 0 or vice-versa. The flicker has an unavoidable one tick delay.  
<img src='https://github.com/AsperTheDog/WireBug/assets/45227294/9d3d2f67-2a4a-465c-aae3-5d72213c3dcf' width='300'>

### Slogger
The slogger has one signal input and one output. The output of the slogger will only change from a power intensity of 15 to that of a 0, alternating only when the input changed from 0 to any value higher than 0. The slogger has an unavoidable one tick delay.  
<img src='https://github.com/AsperTheDog/WireBug/assets/45227294/7c647302-cc4e-4f87-97af-212b6234e437' width='300'>

### Lamp
A lamp only has one omnidirectional input. It will light up when a signal bigger than zero and remain off otherwise. It does not transmit signal to any other neighbor component.  
<img src='https://github.com/AsperTheDog/WireBug/assets/45227294/f3fd1b81-5b3d-451d-810a-7f5d4200609f' width='300'>


## Example
Here there is a quick showcase of a circuit made in the program, this example is a full adder of 2 numbers (of 2-bit size each) into a 3-bit number.
The generators on the top left of the circuit are the inputs (each generator is a bit) and the three lamps are the output

https://github.com/AsperTheDog/RedWire/assets/45227294/a2b78bfe-6760-4b54-9e18-4b95dee74c67

