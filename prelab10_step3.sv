
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
  logic [31:0] entry;
  logic [4:0] keycode;
  logic btnclk;
  scankey sk1 (.clk(hz100), .rst(reset), .in(pb[19:0]), .strobe(btnclk), .out(keycode));
  numentry ne (.clk(btnclk), .rst(reset), .en(1'b1), .in(keycode), .out(entry), .clr(pb[17]));
  display_32_bit d32b (.in(entry), .out({ss7, ss6, ss5, ss4, ss3, ss2, ss1, ss0}));  

  
endmodule

// Add more modules down here...

module numentry(input logic clk, rst, en, clr, input logic [4:0] in, output logic [31:0] out);

  logic [31:0] next_out;
  
  always_ff @(posedge clk) begin
    if (rst)
      out <= 32'b0;
    else if (clr)
      out <= 32'b0;
    else if (en)
      out <= next_out;
  end
  
  always_comb begin
    if (in <= 9)
      if (out == 0)
        next_out = in[3:0];
      else
        next_out = out[31:0] | in[3:0];
    else
      next_out = out;
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

module scankey(input logic clk, input logic rst, input logic [19:0] in, output logic [4:0] out, output logic strobe);
  assign out[0] = in[1] | in[3] | in[5] | in[7] | in[9]  | in[11] | in[13] | in[15] | in[17] | in[19];
  assign out[1] = in[2] | in[3] | in[6] | in[7] | in[10] | in[11] | in[14] | in[15] | in[18] | in[19];
  assign out[2] = in[4] | in[5] | in[6] | in[7] | in[12] | in[13] | in[14] | in[15];
  assign out[3] = in[8] | in[9] | in[10] | in[11] | in[12] | in[13] | in[14] | in[15];
  assign out[4] = in[16] | in[17] | in[18] | in[19];
  
  logic delay0, delay1;
  always_ff @ (posedge clk) begin
    delay1 <= delay0;
    delay0 <= |in[19:0];
    
  end
  assign delay0 = strobe;
endmodule

module clock_1hz(input logic hz100, input logic reset, output logic hz1);
  logic [7:0] Q;
  logic [7:0] next_Q;
  always_ff @ (posedge hz100, posedge reset) begin //1st always_ff with hz100 as clock signal
    if(reset == 1'b1)
    hz1 <= 0;
    else
    hz1 <= (Q == 8'd49);
  end

  
  always_ff @ (posedge hz100, posedge reset) begin //state variables
    
    if(reset == 1'b1)
      Q <= 8'b0;
      
    else
      Q <= next_Q;
  end
  
  always_comb begin //next-state equations
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
