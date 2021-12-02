
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
  logic [3:0] in4;
  logic strobe;
  logic [3:0] out4;
  logic [3:0] state;
  logic [3:0] next_state;
  logic [3:0]outlog;
  ssdec s1(.in(state), .out(ss7[6:0]), .enable(1'b1));
  ssdec s2(.in(next_state), .out(ss5[6:0]), .enable(1'b1));
  ssdec s3(.in(next_state), .out(ss2[6:0]), .enable(1'b1));
  
  always_ff @ (posedge pb[1], posedge pb[0]) 
  begin
  
    if(pb[1] == 1'b1)
      state <= 4'h0;
    else if (pb[0] == 1'b1)
      state <= next_state;
  end
  
  always_comb begin
    case (state)
        4'h0: next_state = 4'hb;
        4'h1: next_state = 4'h3;
        4'h2: next_state = 4'h7;
        4'h3: next_state = 4'h8;
        4'h4: next_state = 4'h1;
        4'h5: next_state = 4'hf;
        4'h6: next_state = 4'h0;
        4'h7: next_state = 4'hd;
        4'h8: next_state = 4'h2;
        4'h9: next_state = 4'he;
        4'ha: next_state = 4'h5;
        4'hb: next_state = 4'h4;
        4'hc: next_state = 4'h9;
        4'hd: next_state = 4'ha;
        4'he: next_state = 4'h6;
        4'hf: next_state = 4'hc;
    endcase
  end
  
  assign left[7:4] = state;
  assign left[3:0] = next_state;
  
  always_comb begin
    case (state)
        4'h0: next_state = 4'h2;
        4'h1: next_state = 4'h7;
        4'h2: next_state = 4'h3;
        4'h3: next_state = 4'h9;
        4'h4: next_state = 4'hf;
        4'h5: next_state = 4'hb;
        4'h6: next_state = 4'he;
        4'h7: next_state = 4'hd;
        4'h8: next_state = 4'h4;
        4'h9: next_state = 4'h6;
        4'ha: next_state = 4'h8;
        4'hb: next_state = 4'h0;
        4'hc: next_state = 4'ha;
        4'hd: next_state = 4'hc;
        4'he: next_state = 4'h1;
        4'hf: next_state = 4'h5;
    endcase
  end

  
  assign right[7:4] = outlog;
  
endmodule

// Add more modules down here...


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
