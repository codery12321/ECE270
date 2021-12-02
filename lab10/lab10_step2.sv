
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
  logic [7:0] ctr;
  logic hz1;
  count8du c8_1(.CLK(hz1), .RST(reset), .DIR(1'b0), .E(ctr != 0), .INIT(8'd5), .Q(ctr));
  clock_1hz cldiv (.hz100(hz100), .reset(reset), .hz1(hz1));
  ssdec s0(.out(ss0[6:0]), .in(ctr[3:0]), .enable(ctr != 0));
  
endmodule

// Add more modules down here...
module clock_1hz(input logic hz100, input logic reset, output logic hz1);
  logic [7:0] Q;
  logic [7:0] next_Q;
  logic new_clk;
  
  always_ff @ (posedge hz100, posedge reset) begin 
    if(reset == 1'b1)
    Q <= 0;
    else
    Q <= (Q == 8'd49) ? 0: next_Q;
  end
  always_ff @ (posedge hz100)
  if (Q == 8'd49)
    new_clk <= 1;
  else
    new_clk <= 0;
  always_ff @ (posedge new_clk, posedge reset) begin 
    if(reset == 1'b1)
      hz1 <= 1'b0;
    else
      hz1 <= ~hz1;
  end
  always_comb begin //next-state equations
      if (Q == 8'd99)
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
endmodule

module count8du(input logic CLK, RST, DIR, E, input logic [7:0]INIT, output logic [7:0] Q);
  logic [7:0] next_Q;
  
  always_ff @ (posedge CLK, posedge RST) begin //state variables
    if(RST == 1'b1)
      Q <= INIT;
    else if (E == 1'b1)
      Q <= next_Q;
  end
  always_comb begin //next-state equations
      if (Q == 0)
        next_Q = INIT;
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
endmodule

module ssdec (input logic [3:0]in, output logic [6:0] out, input logic enable);
    logic [6:0] SEG7 [15:0];
    
    assign SEG7[4'h0] = enable == 1 ? 7'b0111111: 7'b0000000;//012345
    assign SEG7[4'h1] = enable == 1 ? 7'b0000110: 7'b0000000;//12 
    assign SEG7[4'h2] = enable == 1 ? 7'b1011011: 7'b0000000;//01346
    assign SEG7[4'h3] = enable == 1 ? 7'b1001111: 7'b0000000;//01236
    assign SEG7[4'h4] = enable == 1 ? 7'b1100110: 7'b0000000;//1256
    assign SEG7[4'h5] = enable == 1 ? 7'b1101101: 7'b0000000;//02356
    assign SEG7[4'h6] = enable == 1 ? 7'b1111101: 7'b0000000;//023456
    assign SEG7[4'h7] = enable == 1 ? 7'b0000111: 7'b0000000;//012
    assign SEG7[4'h8] = enable == 1 ? 7'b1111111: 7'b0000000;//0123456
    assign SEG7[4'h9] = enable == 1 ? 7'b1100111: 7'b0000000;//01256
    assign SEG7[4'ha] = enable == 1 ? 7'b1110111: 7'b0000000;//012456
    assign SEG7[4'hb] = enable == 1 ? 7'b1111100: 7'b0000000;//23456
    assign SEG7[4'hc] = enable == 1 ? 7'b0111001: 7'b0000000;//0345
    assign SEG7[4'hd] = enable == 1 ? 7'b1011110: 7'b0000000;//12346
    assign SEG7[4'he] = enable == 1 ? 7'b1111001: 7'b0000000;//03456
    assign SEG7[4'hf] = enable == 1 ? 7'b1110001: 7'b0000000;//0456

    
    assign {out[6:0]} = SEG7[in];

endmodule


