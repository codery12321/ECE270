# Pre-Lab Submission 12

## Step 1: A half-adder [2 points]
Construct a half-adder module. The module should be named ha. It should have two single-bit inputs named a and b. It should have two single-bit outputs named s (sum) and co (carry-out).  <br />

You can instantiate and test the half-adder module with the following:
  `ha h1(.a(pb[0]), .b(pb[1]), .s(right[0]), .co(right[1]));`
Include this module in the text box at the bottom of the page. <br />

## Step (2): A full adder built from two half-adders [2 points]
Construct a full adder by instantiating two of the ha half-adder modules you designed for the previous step. You'll need to use an additional OR gate (use a dataflow OR expression) to create the carry-out of the full adder. <br />
The full adder module should be named faha. It should have three input ports named a, b, and ci (carry-in). It should have two output ports named s (sum) and co. <br />

You can instantiate and test the full-adder module with the following:
  `faha f1(.a(pb[0]), .b(pb[1]), .ci(pb[2]), .s(right[0]), .co(right[1]));`
 <br /> Make sure that it satisfies the following truth table: <br />
```
a   b   ci  co  s
0	0	0		0	0
0	0	1		0	1
0	1	0		0	1
0	1	1		1	0
1	0	0		0	1
1	0	1		1	0
1	1	0		1	0
1	1	1		1	1
```
Include this module in the text box at the bottom of the page.

## Step 3: A full adder built from scratch [2 points]
Construct a full adder by writing dataflow expressions for the outputs or by constructing a case statement for each combination of the inputs. Do not instantiate modules you designed for the previous steps.  <br />
The full adder module should be named fa. It should have three input ports named a, b, and ci (carry-in). It should have two output ports named s (sum) and co.  <br />

You can instantiate and test the full-adder module with the following:
  `fa f1(.a(pb[0]), .b(pb[1]), .ci(pb[2]), .s(right[0]), .co(right[1]));`
Make sure that it satisfies the truth table shown in the previous question.   <br />

Include this module in the text box at the bottom of the page.  <br />
## Step 4: A four-bit full adder [4 points]
Construct a four-bit full adder by creating four instances of the fa module you made in the previous step.  <br />
This four-bit full adder module should be named fa4. Inside of this module, you should create four instances of the fa module with the carry-out of each one connected to the carry-in of the next most significant adder. It should have two four-bit input ports named a and b, and a single-bit input named ci (carry-in). It should have a four-bit output port named s (sum) and a single bit output port named co (carry-out). <br />

You can instantiate and test the full-adder module with the following:
  `fa4 f1(.a(pb[3:0]), .b(pb[7:4]), .ci(pb[19]), .s(right[3:0]), .co(right[4]));`
so that the '3'...'0' buttons represent a four-bit input operand, the '7'...'4' buttons represent the second four-bit input operand, and the 'Z' button is the carry-in. The right[3:0] show the sum, and the right[4] shows the carry-out.  <br />

Try testcases such as the following: <br />
```
a	    b	    ci co	s
0000	0000	1		0	0001
1111	0001	0		1	0000
1111	1111	0		1	1110
1111	1111	1		1	1111

```
Include this module in the text box at the bottom of the page.

## Step 5: An eight-bit carry look-ahead adder [5 points]
Construct an eight-bit carry look-ahead adder by eight instances of the ha module you made in step 1. Yes, this is the hard way to do this, but take your time and make it work.
This eight-bit carry look-ahead adder module should be named cla8. It should have two eight-bit input ports named a and b, and a single-bit input named ci (carry-in). It should have an eight-bit output port named s (sum) and a single bit output port named co (carry-out).

You can instantiate and test the adder module with the following:
`  cla8 cl1(.a(pb[7:0]), .b(pb[15:8]), .ci(pb[19]), .s(right[7:0]), .co(red));`
so that the '7'...'0' buttons represent a eight-bit input operand, the 'F'...'8' buttons represent the second eight-bit input operand, and the 'Z' button is the carry-in. The right[7:0] show the sum, and the center red LED shows the carry-out.  <br />

We'll let you come up with your own testcases, but test it well and include this module in the text box at the bottom of the page.  <br />

## Step 6: An eight-bit adder/subtracter [5 points]
Construct an eight-bit adder/subtracter that instantiates the cla8 adder you constructed in the previous step. <br />
This module should be named addsub8. It should have two eight-bit input ports named a and b, and a single-bit input named op to specify whether the operation is (0) addition of A+B or (1) subtraction of A-B. It should have an eight-bit output port named s (sum) and a single bit output port named co (carry-out). <br />

You can instantiate and test this module with the following:
  `addsub8 as1(.a(pb[7:0]), .b(pb[15:8]), .op(pb[18]), .s(right[7:0]), .co(red));`
so that the '7'...'0' buttons represent a eight-bit input operand, the 'F'...'8' buttons represent the second eight-bit input operand, and the 'Y' button specifies the operation. The right[7:0] show the sum, and the center red LED shows the carry-out.  <br />

Here are some example testcases: <br />
```
a	          b	      op	co	s
00000000	00000000	1		1	00000000
00000000	00000001	1		0	11111111
00000000	00000011	1		0	11111101
00000111	00000111	1		1	00000000
```
Include this module in the text box at the bottom of the page.  <br />

## Step 7: A single-digit BCD adder [5 points]
Construct a single-digit (4-bit) BCD adder. This is just a four-bit binary adder with the correction circuit described in lecture module 4-D. <br />
This module should be named bcdadd1. Inside this module, create an instance of the fa4 adder you constructed in a previous step. The module should have two four-bit input ports named a and b, and a single-bit input named ci (carry-in). It should have a four-bit output port named s (sum) and a single bit output port named co (carry-out). <br />

You can instantiate and test this module with the following: <br />
```
  logic co;
  logic [3:0] s;
  bcdadd1 ba1(.a(pb[3:0]), .b(pb[7:4]), .ci(pb[19]), .co(co), .s(s));
  ssdec s0(.in(s), .out(ss0[6:0]), .enable(1));
  ssdec s1(.in({3'b0,co}), .out(ss1[6:0]), .enable(1));
  ssdec s5(.in(pb[7:4]), .out(ss5[6:0]), .enable(1));
  ssdec s7(.in(pb[3:0]), .out(ss7[6:0]), .enable(1));
```
so that the '3'...'0' buttons represent a four-bit input operand, the '7'...'4' buttons represent the second four-bit input operand, and the 'Z' button specifies the carry-in. The ss7 and ss5 displays will show the input operands, and the ss1/ss0 combination will show the two-digit decimal sum.  <br />

Test it thoroughly to make sure it always indicates the decimal sum. Include this module in the text box at the bottom of the page.  <br />

## Step 8: A four-digit BCD adder [10 points]
Construct an four-digit (16-bit) BCD adder. <br />
This module should be named bcdadd4. Inside this module, create four instances of the bcdadd1 adder you constructed in the previous step. Chain the carry-out of each one to the carry-in of the next more significant single-digit BCD adder. The module should have two 16-bit input ports named a and b, and a single-bit input named ci (carry-in). It should have a 16-bit output port named s (sum) and a single bit output port named co (carry-out).  <br />

It's rather difficult to test something like this by pressing buttons. Instead, create successive iterations of static values in the top module instantiation. For instance, you can instantiate and test this module with the following: <br />
```
  logic co;
  logic [15:0] s;
  bcdadd4 ba1(.a(16'h1234), .b(16'h1111), .ci(0), .co(red), .s(s));
  ssdec s0(.in(s[3:0]),   .out(ss0[6:0]), .enable(1));
  ssdec s1(.in(s[7:4]),   .out(ss1[6:0]), .enable(1));
  ssdec s2(.in(s[11:8]),  .out(ss2[6:0]), .enable(1));
  ssdec s3(.in(s[15:12]), .out(ss3[6:0]), .enable(1));
```
You should see the result 2345 on the seven-segment displays. If you change the inputs to 16'h9876 and 16'h3333, the output should show 3209, and the red LED will be illuminated to indicate carry-out. Be sure to try cases with the ci input port set to 1.  <br />

Test it thoroughly to make sure it always indicates the decimal sum. Include this module in the text box at the bottom of the page.  <br />

## Step 9: A nine's-complement circuit [5 points]
Construct a BCD nine's-complement circuit. This is a simple combinational module that accepts a four-bit BCD digit, x, and outputs the digit the value 9-x. You can implement it as a case statement.
This module should be named bcd9comp1. It has one four-bit input in and one four-bit output out.  <br />

You can instantiate and test this module with the following: <br />
```
  logic [3:0] out;
  bcd9comp1 cmp1(.in(pb[3:0]), .out(out));
  ssdec s0(.in(pb[3:0]), .out(ss0[6:0]), .enable(1));
  ssdec s1(.in(out),     .out(ss1[6:0]), .enable(1));
```
pb[3:0] accept a four-bit BCD digit that will be displayed on ss0. The nine's complement should be displayed on ss1. The sum of the digits displayed on ss0 and ss1 should always be 9. It does not matter what is displayed if the input value is greater than 9 (larger than a BCD number).  <br />

Test it thoroughly, and include this module in the text box at the bottom of the page.  <br />
## Step 10: A four-digit ten's-complement adder/subtracter [10 points]
Construct an four-digit BCD ten's-complement adder/subtracter module. This is analogous to how you created the 4-bit binary adder/subtracter. With that module, you computed the one's-complement of the second operand to the adder and then added one to it by setting the carry-in of the adder. This was effectively equivalent to adding the two's-complement inverse to perform a subtraction.  <br />

In this case, you're going to compute the nine's-complement of each BCD digit (using the bcd9comp1 module you just made), and selectively use that as the input to a four-digit BCD adder (bcdadd4) that you constructed earlier. When you carry one into the bcdadd4, you effectively add the ten's-complement inverse to perform a subtraction.  <br />

Of course, the result will be a ten's-complement negative number, which will look very strange. We'll do a better job of displaying that in the lab. <br />
This module should be named bcdaddsub4. It has two 16-bit inputs a and b. It has another one-bit input named op that indicates (0) addition of A+B or (1) subtraction of A-B. It has a 16-bit output named s (sum). There's no need to have a carry-out for this module.  <br />

Once again, it's difficult to test this by pressing buttons. Instead, you can repeatedly instantiate and test this module with static operands: <br />
```
  logic [15:0] s;
  bcdaddsub4 bas4(.a(16'h0000), .b(16'h0001), .op(1), .s(s));
  ssdec s0(.in(s[3:0]),   .out(ss0[6:0]), .enable(1));
  ssdec s1(.in(s[7:4]),   .out(ss1[6:0]), .enable(1));
  ssdec s2(.in(s[11:8]),  .out(ss2[6:0]), .enable(1));
  ssdec s3(.in(s[15:12]), .out(ss3[6:0]), .enable(1));
```
For this example, the 7-segment displays should show 9999, which is the ten's complement way of saying -1.  <br />

Test it thoroughly, and include this module in the text box at the bottom of the page.

You might also try incorporating some of these constructs into the calculator you built for lab 11. That's what we did in previous semesters for lab 12.
