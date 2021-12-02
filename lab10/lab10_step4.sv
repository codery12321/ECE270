
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
  //STEP2
    /*logic [7:0] ctr;
    logic hz1;
    count8du c8_1(.CLK(hz1), .RST(reset), .DIR(1'b0), .E(ctr != 0), .INIT(8'd5), .Q(ctr));
    clock_1hz cldiv (.hz100(hz100), .reset(reset), .hz1(hz1));
    ssdec s0(.out(ss0[6:0]), .in(ctr[3:0]), .enable(ctr != 0));*/
  //STEP3
    /*logic [7:0] ctr1, ctr2, ctr3, ctr4;
    count8du_init flashnum1 (.CLK(hz100), .RST(reset), .DIR(1'b0), .E(ctr1 != 0), .INIT(8'h99), .Q(ctr1));
    count8du_init flashnum2 (.CLK(hz100), .RST(reset), .DIR(1'b0), .E(ctr2 != 0), .INIT(8'hAB), .Q(ctr2));
    count8du_init flashnum3 (.CLK(hz100), .RST(reset), .DIR(1'b0), .E(ctr3 != 0), .INIT(8'hCD), .Q(ctr3));
    count8du_init flashnum4 (.CLK(hz100), .RST(reset), .DIR(1'b0), .E(ctr4 != 0), .INIT(8'hEF), .Q(ctr4));
    display_32_bit show_entry (.in({ctr1, ctr2, ctr3, ctr4}), .out({ss7, ss6, ss5, ss4, ss3, ss2, ss1, ss0}));*/
    
  //STEP4
    simon game (.clk(hz100), .reset(reset), .in(pb[19:0]), .left(left), .right(right), 
      .ss({ss7, ss6, ss5, ss4, ss3, ss2, ss1, ss0}), .win(green), .lose(red));
endmodule

// Add more modules down here...
module display_32_bit (input logic [31:0] in, output logic [63:0] out);
  ssdec s0(.out(out[6:0]), .in(in[3:0]), .enable(1'b1));
  ssdec s1(.out(out[14:8]), .in(in[7:4]), .enable(|in[31:4]));
  ssdec s2(.out(out[22:16]), .in(in[11:8]), .enable(|in[31:8]));
  ssdec s3(.out(out[30:24]), .in(in[15:12]), .enable(|in[31:12]));
  ssdec s4(.out(out[38:32]), .in(in[19:16]), .enable(|in[31:16]));
  ssdec s5(.out(out[46:40]), .in(in[23:20]), .enable(|in[31:20]));
  ssdec s6(.out(out[54:48]), .in(in[27:24]), .enable(|in[31:24]));
  ssdec s7(.out(out[62:56]), .in(in[31:28]), .enable(|in[31:28]));
  assign out[7] = 0;
  assign out[15] = 0;
  assign out[23] = 0;
  assign out[31] = 0;
  assign out[39] = 0;
  assign out[47] = 0;
  assign out[55] = 0;
  assign out[63] = 0;

endmodule

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
    if (in <= 9) begin
      if (out == 0)begin
         next_out = {28'b0, in[3:0]};
      end
      else begin
        next_out = (out << 4) |{28'b0, in[3:0]};
      end
    end
    else
      next_out = out;
  end

endmodule
module count8du_init(input logic CLK, RST, DIR, E, input logic [7:0]INIT, output logic [7:0] Q);
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

module simonctl(input logic clk, rst, lvlmax, win, lose, output logic state);
  logic next_state;
  typedef enum logic { RDY, ENT } simonstate_t; //defines the states RDY and ENT for us as 0 and 1
  
  //asynchronously reset state to RDY when a rising edge rst occurs
    //otherwise to set state to a new logic signal named next_state.
  always_ff @ (posedge clk, posedge rst) begin
    if (rst == 1'b1)
      state <= RDY;
    else
      state <= next_state;
  end
  
  always_comb begin
    if (lose | (~lvlmax & win))
      next_state = RDY;
    else if (~lvlmax)
      next_state =  ENT;
      
    else
    next_state = state;
  end
  
endmodule