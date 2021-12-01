# Pre-Lab Submission 9
## Step 1: An 8-bit modulo counter [10 points]

With the help of the code given to you in Module 3-F for the "Basic 8-bit binary up-counter", design an 8-bit counter that counts to 99, and then starts over from 0. The counter must be designed as a separate module named count8du, with the following ports:

- A 1-bit logic input called CLK
- A 1-bit logic input called RST (which you will need to add to the code from the slides), and
- An 8-bit logic output called Q
To make it count to 99 and restart, you will need to modify the always_comb block to set the value of next_Q to 0 when Q is equal to 8'd99, otherwise continue to increment Q by 1 by using the equations for next_Q provided in the code.
You should really use the examples from lecture module 3-F. Do not use the '+' operator. You haven't learned how to use that yet. You might look at the examples of reduction operators in homework 8. For instance, instead of typing out something like "x[3] & x[2] & x[1] & x[0]" you can say, instead, "&x[3:0]". The AND prefix is applied to all elements of the bus. This works for all of the Boolean binary operators like '|' and '^'. The use of reduction operators make it possible to succinctly specify the next-state equations for counter.

In the top module, instantiate this module with the name c8_1, and connect CLK to hz100, RST to reset, and Q to right. To ensure that your counter is working correctly, you should see that the right[7] LED is never illuminated. You will also notice that the right[6] LED blinks at a rate of once per second. This is because it counts from 0 ... 99 (100 steps) repeatedly. Each step of the count takes 1/100 of a second, and so every full count from 0 to 99 (100 steps) should take exactly one full second. The right[6] LED is on when the decimal value of the count is between 64 and 99, or approximately 1/3 of the time of the full count.

The reset should be an asynchronous reset. It should not wait for the next rising edge of the clock to take effect. Submit your Verilog code, including your top module and other relevant modules below.

# ECE 270 Lab Experiment 9: Counters, State Machines, and Hangman

## Introduction

This lab will have you develop a binary up counter, and make modifications to it to give it the capability of counting both up and down and counting to a variable limit, then using it as a prescaler for the hz100 clock signal that you may have noticed in the top module template.

The 'hz100' signal toggles at a frequency of 100 Hz (hence the name) and is capable of being used in designs that require accurate clock signals, such as stopwatches and timers. We can build these devices with the help of counters, and use these devices to build (hopefully) fun games. :)

## Step 0: Prelab

- Read the notes for module 3-F.
- Read the entire lab document.
- Do the prelab assignment on the course web page.

## Step 1: Modify prelab counter to add up/down counting mode

**Re-run the ece270-setup script to get a lab09 folder, which will contain the files necessary to implement your design.**
**At this point, you should have a verified counter that is able to count to 8'd99 as indicated by the output, and upon reaching 8'd99, will restart at zero on the next clock toggle. The counter must be a module named count8du, and the only additional line in your top module must be the module instantiation of count8du, i.e. all counter-based logic must be in your count8du module and not your top module.**

For this step, you will modify the count8du module that you wrote in the prelab to be able to make it count up or down based on a new input. To start, add a new 1-bit input called DIR to your module's port header (alongside input logic CLK, RST, and output logic [7:0] Q). In the module instantiation in your top module, add the DIR port and connect it to pb[17].

Copy the count8du module you wrote in the prelab below your top module in your top.sv file/simulator tab. In the always_comb block of your module, modify your logic so that:

- If DIR is equal to zero, the value of next_Q is updated to Q - 1. Do not actually use Q - 1. Change the equations for the individual bits to do this. If the value of Q is zero, next_Q should be equal to 8'd99.
- Else, if DIR is equal to one, the value of next_Q is updated to Q + 1. Do not actually use Q + 1. Change the equations for the individual bits to do this. If the value of Q is 8'd99, next_Q should be equal to 0.
Ensure that your design matches the output shown below. Similar to how you ensured that your design counted to 8'd99 and then started again at 0 in your prelab, ensure that your counter goes all the way from 8'd99 to 0 when counting down, and from 0 to 8'd99 when counting up, and restarts accordingly.


>Show your design on the FPGA to your TA to receive a checkoff. TAs will ensure that your design is able to count both up and down by pressing and releasing pb[17] respectively.

## Step 2: Modify prelab counter to count to an arbitrary number N

For this step, you will modify the count8du module from the previous step to make it count to any number N (inclusive), rather than just 8'd99. To start, add a new 8-bit input called MAX to your module's port header and in the module instantiation in your top module, add the MAX port and connect it to a Verilog literal 8'd49.

Since you already have logic in place to set next_Q to a specific value (8'd99) from earlier, all you have to do is replace those occurrences of 8'd99 with MAX.

As a result, your counter should now reset to zero twice as fast as the previous version. It should function as shown below:


>Show your design on the FPGA to your TA to receive a checkoff. TAs will ensure that your design is able to count to a specific value by specifying it in the code and watching the flashed design.
We recommend changing MAX in the top module to different values to see if the counter correctly counts to and from the specified limit.

## Step 3: Modify prelab counter to count only when an enable E is asserted

For this step, you will modify the count8du module from the previous step to make it count only when an enable input E is asserted. To start, add a new 1-bit input called E to your module's port header, and in the module instantiation in your top module, add the E port and connect it to pb[18] (the Y pushbutton).

As a result, your counter should not count as long as pb[18]/Y is not held. It will only start counting when you hold down the button.

>Show your TA your working design with the enable input. Your TA will check that the counter stops when the Y button is released, and starts again when the Y button is pressed.

## Step 4: Use your counter as a hz100 clock prescaler and verify it

**For this step, it is extremely crucial that your instance name for count8du in the top module from the previous step is c8_1 - if it is not, your code will not be correctly verified!**
Now that we have a counter capable of changing direction and value limit, we can use this as a prescaler for the hz100 signal. If you wanted to make a stopwatch, for example, a prescaler could theoretically divide down the frequency of the hz100 signal (intuitively, you should know it is 100 Hz, or one can say that the signal goes high every 0.01 seconds) to smaller values like 50, 25, 10 or even 1 Hz, turning the counter into a second-timer.

In your top module, create two 1-bit signals called flash and hz1, and an 8-bit bus called ctr. Replace right in the count8du Q port connection with ctr, and change DIR to 1'b0, and E to 1'b1 so you don't have to hold down the buttons.

In order to flash a signal at 1 Hz, we can check if the counter reaches a specific value given a known clock speed. In our case, we have a 100 Hz clock in hz100. If we count to 99, we know that it takes 100 clock cycles to reach that value from 0, so reaching 99 means a full second has passed.

However, we only have a very short period of time before that 99 changes to 0. On the simulator, this results in a weird pulse signal that looks unreliable to use as a clock signal somewhere else. We will therefore use a toggle flip-flop that will be ON for half the period, and OFF for the other half, as our clock.

To do this, create an always_ff block with hz100 as the clock signal and reset as the reset signal. In it, set hz1 to 0 if reset is high, otherwise set it to the expression "ctr == 8'd49". (Why 49 and not 99? Try both values after you've fully written the code. Which one gives you a 1 Hz clock?)

Create a second always_ff block with hz1 as the clock, and reset as the reset signal. In it, set flash to 0 if reset is high, otherwise set it to the inverse of flash.

Connect flash to blue, and run your code. You should see a 1 Hz flash on the blue LED in the center of the FPGA.

Finally, run "make verify" to do a final check of your count8du module. It should look like this:



**If you are doing this on the simulator, make sure to do this when you get to lab.**
>Show the verification waveform to your TA, as well as the 1-Hz-flashing blue LED to get credit for this step.

## Step 5: Integrate your submodules into the Hangman game

**Before starting this step, copy the ssdec module that you built for lab 6 below your top module, in the file/simulator tab that you're working in.**
If you haven't played this before, Hangman is a very simple game where you guess a unknown word with a limited number of tries. On the FPGA board, we'll use words made from the letters A, B, C, D, E, F. If you look at the pushbuttons, you'll understand why we have this odd limitation. We'll limit it to six tries - two free tries + the length of the word - and have you try guessing different words.

Since Hangman makes use of code that you will eventually write, we've only given you the ability to instantiate the module in your code, but not actually read the module yourself. If seeing this game piques your interest and gets you wondering how to write this design yourself, that's a good sign - just wait for next week's lab to learn these concepts!

To set it up:

- If you're doing this in the lab, all you need to do is write the instantiation below in your top module. Hangman is available as hangman.json (a gate-level netlist generated from our code) in your lab09 folder.
- If you are doing this on the simulator, make sure to add the hangman module to your workspace file list by going to the workspace settings (the gear icon on the workspace tab) and ticking the box for "hangman.sv", in addition to writing the instantiation below in your top module.
Write the following instantiation into your top module and simulate/run "make cram".
```
hangman hg (.hz100(hz100), .reset(pb[19]), .hex(pb[15:10]), .ctrdisp(ss7[6:0]), .letterdisp({ss3[6:0], ss2[6:0], ss1[6:0], ss0[6:0]}), .win(green), .lose(red), .flash(flash));
```
You should see a counter on ss7 initialized to 6. Try guessing the word by pressing the A-F pushbuttons. If you pick a letter, the game will check if you pressed a letter that exists in the word, and display the letter if it exists. Notice the counter will decrease by 1 with each try.

You win the game if you manage to guess the full word before the six tries are up, when the green LED will flash at 1 Hz - this is possible because of the counter you wrote! You lose if you reach zero and did not manage to find all the letters, as a result of which the red LED will flash at 1 Hz. You can try a new word by pressing "Z".

Questions or comments about the course and/or the content of these webpages should be sent to the Course Webmaster. All the materials on this site are intended solely for the use of students enrolled in ECE 270 at the Purdue University West Lafayette Campus. Downloading, copying, or reproducing any of the copyrighted materials posted on this site (documents or videos) for anything other than educational purposes is forbidden.
