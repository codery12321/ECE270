`default_nettype none

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

  // Step 1.5
  // Instantiate the Lunar Lander and set up a slower clock
  logic [3:0] shift;
  logic hzX;
  always_ff @(posedge hz100, posedge reset)
    if (reset)
      shift <= 4'b1;
    else
      shift <= {shift[2:0], shift[3]};
  assign hzX = shift[3];
  lunarlander #(16'h800, 16'h4500, 16'h0, 16'h5) ll (
    .hz100(hz100), .clk(hzX), .rst(reset), .in(pb[19:0]), .crash(red), .land(green),
    .ss({ss7, ss6, ss5, ss4, ss3, ss2, ss1, ss0})
  );
endmodule

module lunarlander #(
  parameter FUEL=16'h800,
  parameter ALTITUDE=16'h4500,
  parameter VELOCITY=16'h0,
  parameter THRUST=16'h5,
  parameter GRAVITY=16'h5
  )(
  input logic hz100, clk, rst,
  input logic [19:0] in,
  output logic [63:0] ss,
  output logic crash, land
);

  // Step 1.1
  // Use your bcdaddsub4 module to calculate landing parameters
  logic [15:0] alt, vel, fuel, thrust, newalt, newvel, newfuel, manualthrust;
  bcdaddsub4 bas4(.a(alt), .b(vel), .op(1'b0), .s(newalt)); 
  logic [15:0] intval;
  bcdaddsub4 subtract(.a(vel), .b(GRAVITY), .op(1'b1), .s(intval));
  bcdaddsub4 add(.a(intval), .b(thrust), .op(1'b0), .s(newvel));
  bcdaddsub4 new_fuel(.a(fuel), .b(thrust), .op(1'b1), .s(newfuel));
  
  // Step 1.2
  // Set up a modifiable thrust register
  logic [4:0] keycode;
  logic strobe;
  scankey sk1 (.clk(hz100), .rst(rst), .in(in[19:0]), .strobe(strobe), .out(keycode));
  always_ff @(posedge strobe,  posedge rst)
    if (rst == 1'b1)
      manualthrust <= THRUST;
    else
      manualthrust <= {11'b0, keycode};
      
  // Step 1.3
  // Set up the state machine logic for the lander
  typedef enum logic [2:0] {INIT=0, CALC=1, SET=2, CHK=3, HLT=4} flight_t;
  logic [2:0] flight;
  logic nland, ncrash;
      
  always_ff @ (posedge clk, posedge rst) begin
    if(rst) begin
      flight <= INIT;
      crash <= 1'b0;
      land <= 1'b0;
      ncrash <= 1'b0;
      nland <= 1'b0;
      fuel <= FUEL;
      alt <= ALTITUDE;
      vel <= VELOCITY;
      thrust <= THRUST;
    end
    else begin
      case(flight)
        INIT: flight <= CALC;
        CALC: flight <= SET;
        SET: begin begin if (newfuel[15] == 1)
                    fuel <= 0; 
                   else
                    newfuel[15] <= newfuel; 
                   alt <= newalt; 
                   vel <= newvel; end
                   if(newfuel <= 0 || fuel == 0)
                      thrust <= 0;
                   else 
                    thrust <= manualthrust;
                   flight <= CHK; end
        CHK: begin if ((newalt[15] == 1) && (thrust <= 5) && (newvel > 16'h9970)) begin
                    nland <= 1;
                    flight <= HLT; end
                    else if (newalt[15] == 1) begin
                      ncrash <= 1;
                      flight <= HLT; end
                    else 
                      flight <= CALC; end
        HLT: begin land <= nland; crash <= ncrash; alt <= 0; vel <= 0; end
      endcase
    end    
  end
  // Step 1.4
  // Set up the display mechanics
  
  logic [23:0] lookupmsg [3:0];
  logic [1:0] sel;
  logic [15:0] val;
  always_comb begin
    lookupmsg[0] = 24'b011101110011100001111000;  // alt
    lookupmsg[1] = 24'b001111100111100100111000;  // vel
    lookupmsg[2] = 24'b011011110111011101101101;  // fuel (says gas)
    lookupmsg[3] = 24'b011110000111011001010000;  // thrust
    case(sel)
      0: val = alt;
      1: val = vel;
      2: val = fuel;
      3: val = thrust;
    endcase
  end
  logic [15:0] negval;
  bcdaddsub4 negvalout(.a(16'b0), .b(val), .op(1'b1), .s(negval)); 
  logic [63:0] valdisp, negvaldisp;
  display_32_bit show_val (.in({16'b0, val}), .out(valdisp));
  display_32_bit show_negval (.in({16'b0, negval}), .out(negvaldisp));
  always_comb begin
    if (val < 0)
      ss = {lookupmsg[sel], 8'b0, 8'b01000000, negvaldisp[23:0]};
    else
      ss = {lookupmsg[sel], 8'b0, valdisp[31:0]};
  end
  always_ff @(posedge strobe, posedge rst)
    if(rst)
       sel <= 0;
    else begin
      case (keycode)
        5'b10000: sel <= 3;
        5'b10001: sel <= 2;
        5'b10010: sel <= 1;
        5'b10011: sel <= 0;
      endcase
    end

endmodule
module bcdaddsub4 (input logic [15:0] a, b, input logic op, output logic [15:0]s);
    logic [3:0]out1, out2, out3, out4;
    logic [15:0]cin, bNew;
    bcd9comp1 cmp1(.in(b[3:0]), .out(out1));
    bcd9comp1 cmp2(.in(b[7:4]), .out(out2));
    bcd9comp1 cmp3(.in(b[11:8]), .out(out3));
    bcd9comp1 cmp4(.in(b[15:12]), .out(out4));
    assign cin = {out4, out3, out2, out1};
    assign bNew = op == 1 ? cin : b;
    bcdadd4 ba1(.a(a), .b(bNew), .ci(op), .co(), .s(s));
endmodule
module bcdadd4 (input logic [15:0] a, b, input logic ci, output logic co,output logic [15:0]s);
    logic co1, co2, co3;
    bcdadd1 ba1(.a(a[ 3: 0]), .b(b[ 3: 0]), .ci(ci ), .co(co1), .s(s[ 3: 0]));
    bcdadd1 ba2(.a(a[ 7: 4]), .b(b[ 7: 4]), .ci(co1), .co(co2), .s(s[ 7: 4]));
    bcdadd1 ba3(.a(a[11: 8]), .b(b[11: 8]), .ci(co2), .co(co3), .s(s[11: 8]));
    bcdadd1 ba4(.a(a[15:12]), .b(b[15:12]), .ci(co3), .co(co ), .s(s[15:12]));
endmodule
module bcd9comp1(input logic [3:0]in, output logic [3:0]out);
  always_comb
    case(in)
      4'b0000: out = 4'b1001;
      4'b0001: out = 4'b1000;
      4'b0010: out = 4'b0111;
      4'b0011: out = 4'b0110;
      4'b0100: out = 4'b0101;
      4'b0101: out = 4'b0100;
      4'b0110: out = 4'b0011;
      4'b0111: out = 4'b0010;
      4'b1000: out = 4'b0001;
      4'b1001: out = 4'b0000;
      default: out = 4'b0000;
    endcase
endmodule
module bcdadd1 (input logic [3:0]a, b, input logic ci, output logic co, output logic [3:0]s);
  logic [3:0]z, bNew;
  logic cout;
  fa4 f1(.a(a), .b(b), .ci(ci), .s(z), .co(cout));
  assign co = cout | z[3] & z[2] | z[3] & z[1];
  assign bNew = {1'b0, co, co, 1'b0};
  fa4 add(.a(bNew), .b(z), .ci(1'b0), .s(s), .co());
endmodule
module fa4(input logic [3:0]a, b, input logic ci, output logic [3:0] s, output logic co);
  logic co1, co2, co3;

  fa f1(.a(a[0]), .b(b[0]), .ci(ci), .s(s[0]), .co(co1));
  fa f2(.a(a[1]), .b(b[1]), .ci(co1), .s(s[1]), .co(co2));
  fa f3(.a(a[2]), .b(b[2]), .ci(co2), .s(s[2]), .co(co3));
  fa f4(.a(a[3]), .b(b[3]), .ci(co3), .s(s[3]), .co(co));
endmodule
module fa (input logic a, b, ci, output logic s, co);
  assign s = a ^ b ^ ci;
  assign co = a &b | a&ci | b&ci;
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
module display_32_bit (input logic [31:0] in, output logic [63:0] out);
  ssdec s0(.out(out[6:0]), .in(in[3:0]), .enable(1'b1));
  ssdec s1(.out(out[14:8]), .in(in[7:4]), .enable(|in[31:4]));
  ssdec s2(.out(out[22:16]), .in(in[11:8]), .enable(|in[31:8]));
  ssdec s3(.out(out[30:24]), .in(in[15:12]), .enable(|in[31:12]));
  ssdec s4(.out(out[38:32]), .in(in[19:16]), .enable(|in[31:16]));
  ssdec s5(.out(out[46:40]), .in(in[23:20]), .enable(|in[31:20]));
  ssdec s6(.out(out[54:48]), .in(in[27:24]), .enable(|in[31:24]));
  ssdec s7(.out(out[62:56]), .in(in[31:28]), .enable(|in[31:28]));
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