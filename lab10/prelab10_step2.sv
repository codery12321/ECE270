
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
  logic strobe;
  logic [4:0] keycode;
  scankey sk1 (.clk(hz100), .rst(reset), .in(pb[19:0]), .strobe(strobe), .out(keycode));
  assign right[0] = strobe;
  assign right[5:1] = keycode;
  
endmodule

// Add more modules down here...
module scankey(input logic clk, input logic rst, input logic [19:0] in, output logic [4:0] out, output logic strobe);
  assign out[0] = in[1] | in[3] | in[5] | in[7] | in[9]  | in[11] | in[13] | in[15] | in[17] | in[19];
  assign out[1] = in[2] | in[3] | in[6] | in[7] | in[10] | in[11] | in[14] | in[15] | in[18] | in[19];
  assign out[2] = in[4] | in[5] | in[6] | in[7] | in[12] | in[13] | in[14] | in[15];
  assign out[3] = in[8] | in[9] | in[10] | in[11] | in[12] | in[13] | in[14] | in[15];
  assign out[4] = in[16] | in[17] | in[18] | in[19];
  
  logic delay0, delay1;
  logic [3:0] next_out;
  always_ff @ (posedge clk, posedge rst) begin
    if(rst) begin
    delay0 <= 0;
    delay1 <= 0;
    end
    else begin
    delay0 <= |in[19:0];
    delay1 <= delay0;
    end
  end
  assign strobe = delay1;
endmodule

module clock_1hz(input logic hz100, input logic reset, output logic hz1);
  logic [7:0] Q;
  logic [7:0] next_Q;
  logic new_clk;
  
  always_ff @ (posedge hz100, posedge reset) begin //1st always_ff with hz100 as clock signal
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
  
  always_ff @ (posedge new_clk, posedge reset) begin //state variables
    
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


