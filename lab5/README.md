# Pre-Lab Submission 5

This lab is about implementing functions using decoders. For the actual lab experiment, you will use the 74HC138 3-to-8 decoder with active-low outputs. For the prelab, you will model the work with Verilog.

### Implementing logic functions

To implement logic functions, you must understand how a decoder works. Lecture 2-G should make clear that a decoder is a mechanism for taking a binary encoded input and making the corresponding output active. In the case of a 3-to-8 decoder, the 3-bit input code can have one of eight combinations. The number that the input represents causes the output number to be active. In this regard, the eight outputs can be thought of as the minterm number. For instance, if the input to a 3-to-8 decoder is 011, it represents the decimal number three. The output three represents minterm 3. If the inputs represent symbols X,Y, and Z, then a 011 input would represent the product term X'*Y*Z. Each output represents the AND of each relevant literal component. Output 3 represents the AND of X', Y, and Z.

You know that a sum-of-products representation of a logic function is the OR of the constituent minterms. For example, the expression X'*Y*Z + X*Y'*Z + X*Y*Z corresponds to the logical sum of minterms 3, 5, and 7. A three-input OR gate connected to those outputs of the decoder would implement the function.

### Decoders with active-low outputs

If an decoder with active-high outputs, as just described, whose outputs represent the AND of literal product elements, can be used with an OR gate to produce a sum-of-products expression, then we can use DeMorgan's Law to turn the AND-OR tree into a NAND-NAND tree. A decoder with inverted outputs can be thought of as a NAND of the literal product components. If another NAND is used to "sum" multiple outputs together, the result is the NAND-NAND equivalent of the sum-of-products expression.

For the previous example, to implement X'\*Y\*Z + X\*Y'\*Z + X\*Y\*Z, we know that a 3-to-8 decoder with active-low outputs represents (X'\*Y\*Z)' with output 3, (X\*Y'\*Z)' with output 5, and (X\*Y\*Z)' with output 7. By using an enclosing NAND for all three terms, we get:

`((X'*Y*Z)' * (X*Y'*Z)' * (X*Y*Z)' )'`
Which, by DeMorgan's Law is equivalent to:
	  `(X'*Y*Z)  + (X*Y'*Z)  + (X*Y*Z)`
### Implementing the complement of a function

The complement of an expression can also be realized by using an AND gate instead of a NAND.

### Details about the 74HC138

The 74HC138 is a 3-to-8 decoder with active-low outputs, and it can be used in this manner. It also has three enable inputs. All of these enable inputs must be properly set for any of the outputs to become active. Two of the enable inputs, e1 and e2, are active-low, and the third, e3, is active-high. For any output to be active (low) e1 and e2 must be low, and e3 must be high.

### Building a 4-to-16 decoder from two 74HC138 chips

The three enable signals are arranged as they are to allow easy creation of a larger decoder. For instance, consider the case where two 74HC138 chips are used, with selection signals X,Y,Z connected to the 3 inputs of each. A fourth selection signal, W, could be added by connecting (0,W,1) to e1,e2,e3 of one chip, and connecting (0,0,W) to e1,e2,e3 of the second chip. This means that the first chip's outputs will be enabled when W is low (to make e2 active), and the second chip's outputs will be enabled when W is high (to make e3 active). The result is a 4-to-16 decoder, where the first chips eight outputs represent minterms 0 – 7, and the second chip's outputs represent minterms 8 – 15.

### Your logic functions for the lab experiment

The logic functions you are to realize, for both this prelab as well as the lab are as follows:
```
F0(R,S,T,U) = R'·S'·T'·U + R'·S·T·U' + R·S'·T'·U'
F1(R,S,T,U) = R'·S·T'·U' + R'·S·T·U + R·S·T'·U
F2(R,S,T,U) = R'·S'·T'·U' + R'·S'·T·U' + R'·S'·T·U
F3(R,S,T,U) = R·S'·T'·U + R·S·T·U' + R·S·T·U
F4(R,S,T,U) = R'·S·T'·U + R·S'·T·U' + R·S·T'·U'
F5(R,S,T,U) = R'·S'·T'·U' + R'·S'·T'·U + R'·S'·T·U' + R'·S'·T·U + R'·S·T'·U' + R'·S·T·U' + R'·S·T·U + R·S'·T'·U' + R·S'·T'·U + R·S'·T·U + R·S·T'·U' + R·S·T'·U + R·S·T·U' + R·S·T·U
F6(R,S,T,U) = R'·S'·T'·U' + R'·S'·T'·U + R'·S'·T·U' + R'·S'·T·U + R'·S·T'·U' + R'·S·T'·U + R'·S·T·U' + R'·S·T·U + R·S'·T'·U' + R·S'·T'·U + R·S'·T·U' + R·S'·T·U + R·S·T'·U + R·S·T·U'
F7(R,S,T,U) = R'·S'·T'·U' + R'·S'·T'·U + R'·S'·T·U' + R'·S'·T·U + R'·S·T'·U' + R'·S·T'·U + R'·S·T·U' + R'·S·T·U + R·S'·T'·U' + R·S'·T·U' + R·S'·T·U + R·S·T'·U' + R·S·T'·U + R·S·T·U
```
To implement this, recognize that each constituent product term can be translated to a minterm number. For an active-low decoder, each result can be represented by the NAND of the inverted outputs. When there are many terms, the complement of the function can be more easily implemented by using an AND gate.

Implement these functions in the top module of your design as follows:
- Use pb[3:0] represent R,S,T, and U, respectively.
- Add the SystemVerilog model of the 74HC138 to your design. Create two instances of it, and wire their enable pins to form a 4-to-16 decoder.
- Create a single 16-bit output bus named p (for product terms) and connect the appropriate halves of it to the outputs of the hc138 instances.
- Create dataflow expressions to form NAND expressions of the p elements. For each expression that has more than three product terms, implement it using an AND of the appropriate product terms.
- Represent the F7, F6, ... F1, F0 results on right[7:0].

Test your outputs to ensure that all eight outputs are activated for the proper combinations of buttons 3,2,1,0.

Development hint: To get started, you may wish to wire the outputs of the two hc138 instances to {left,right} just to make sure that you have properly created a 4-to-16 decoder with active-low outputs. No matter what combinations buttons 3,2,1,0 are in, one and only one of the 16 left and right LEDs should be off for such a system. Be sure to disconnect the left and right LEDs before implementing your logic functions.


## Step 1: Implementing Boolean functions with decoders [16 points]

Let's get started by writing the equations, using Verilog dataflow syntax, for each of your functions, in terms of the p bus elements. For instance, if you wanted to realize

`F0(R,S,T,U) = R'·S'·T'·U' + R'·S'·T'·U`

you can determine that the two minterms are 0000 and 0001, respectively. The components of the active-low decoder to NAND together would be elements 0 and 1 of the p bus. This would be implemented with a dataflow NAND as

`assign right[0] = ~( p[0] & p[1] );`

Remember to use a dataflow AND to form the complement of any expressions with more than three terms.
```
assign right[0] = ~(p[1] & p[6] &p[8]);
assign right[1] = ~(p[4] & p[7] & p[13]);
assign right[2] = ~(p[0] & p[2] & p[3]);
assign right[3] = ~(p[9] & p[14] & p[15]);
assign right[4] = ~(p[5] & p[10] &p[12]);
assign right[5] = p[5]  & p[10];
assign right[6] = p[12] & p[15];
assign right[7] = p[9] & p[14];
```

## Step 2: [20 points]

Create a SystemVerilog file in the simulator, test it well, and upload it here. Include both the top and hc138 module definitions. All of the statements to implement the specified functions should be in the top module.

Are you ready to wire the lab experiment? Make sure you have two 74HC138 decoders, two 74HC10 triple 3-input NAND gate chips, and a 74HC08 AND gate chip. You will need 8 LEDs (of any color you like) to represent the outputs, and four push buttons to use as inputs. When you've tested your circuit, you will plug in the AD2 and use Autotest to evaluate it.
