`default_nettype none
// Empty top module

module top (
  // I/O ports
  input  logic hz100, reset, 
  input  logic [20:0] pb,
  output logic [7:0] left, right, 
         ss7, ss6, ss5, ss4, ss3, ss2, ss1, ss0,
  output logic red, green, blue,

  // UART ports
  output logic [7:0] txdata,
  input  logic [7:0] rxdata,
  output logic txclk, rxclk,
  input  logic txready, rxready
);

  // Your code goes here...
  count8du c8_1(.CLK(hz100), .RST(reset), .DIR(1'b0), .E(1'b1), .MAX(8'd49), .Q(ctr));
  logic flash, hz1;
  logic [7:0]ctr;
  
  always_ff @ (posedge hz100, posedge reset) begin //1st always_ff with hz100 as clock signal
    if(reset == 1'b1)
    hz1 <= 0;
    else
    hz1 <= (ctr == 8'd49);
  end
  
  always_ff @ (posedge hz1, posedge reset) begin//2nd always block with hz1 as clock signal
    if (reset == 1'b1)
    flash <= 0;
    else
    flash <= ~flash;
  end
    
  assign blue = flash;
  
endmodule

// Add more modules down here...
module count8du(input logic CLK, RST, DIR, E, input logic [7:0]MAX, output logic [7:0] Q);
  
  
  logic [7:0] next_Q;
  always_ff @ (posedge CLK, posedge RST) begin //state variables
    
    if(RST == 1'b1)
      Q <= 8'b0;
      
    else if (E == 1'b1)
      Q <= next_Q;
  end
  
  always_comb begin //next-state equations
    if (DIR == 1'b1) begin
      if (Q == 0)
        next_Q = 8'd99;
      else begin
        next_Q[0] = ~Q[0];
        next_Q[1] = Q[1] ^ ~Q[0];
        next_Q[2] = Q[2] ^ (~Q[1] & ~Q[0]);
        next_Q[3] = Q[3] ^ (~Q[2] & ~Q[1] & ~Q[0]);
        next_Q[4] = Q[4] ^ (~Q[3] & ~Q[2] & ~Q[1] & ~Q[0]);
        next_Q[5] = Q[5] ^ (~Q[4] & ~Q[3] & ~Q[2] & ~Q[1] & ~Q[0]);
        next_Q[6] = Q[6] ^ (~Q[5] & ~Q[4] & ~Q[3] & ~Q[2] & ~Q[1] & ~Q[0]);
        next_Q[7] = Q[7] ^ (~Q[6] & ~Q[5] & ~Q[4] & ~Q[3] & ~Q[2] & ~Q[1] & ~Q[0]);
      end
      
    end 
     
    else begin
      if (Q == MAX)
        next_Q = 8'b0; //d or b doesn't matter
      else begin
        next_Q[0] = ~Q[0];
        next_Q[1] = Q[1] ^ Q[0];
        next_Q[2] = Q[2] ^ (&Q[1:0]);
        next_Q[3] = Q[3] ^ (&Q[2:0]);
        next_Q[4] = Q[4] ^ (&Q[3:0]);
        next_Q[5] = Q[5] ^ (&Q[4:0]);
        next_Q[6] = Q[6] ^ (&Q[5:0]);
        next_Q[7] = Q[7] ^ (&Q[6:0]);
     end      
    end
  end
  
endmodule



