// r10v64 ARM 5 — PORT-CONNECTION LITERAL SHAPES for § connIpsBareBaseUint64.
// Every base spelling an indexed part select can carry, every home, +: and -:,
// bare and sized widths.  MEASUREMENT ONLY.
module leafV5 #(parameter int W = 4)(input [W-1:0] a, input [W-1:0] b, output e);
  assign e = |a ^ |b;
endmodule

module midV5 #(parameter int BW = 4)(input [31:0] bus, output [15:0] o);
  localparam int PZ  = 0;
  localparam int PONE = 1;
  localparam bit [7:0] PH = 8'h0;
  // ---- MODULE BODY home ---------------------------------------------------
  leafV5 #(.W(BW)) m0 (.a(bus[0    +: BW]), .b(bus[0    +: BW]), .e(o[0]));
  leafV5 #(.W(BW)) m1 (.a(bus[1    +: BW]), .b(bus[15   -: BW]), .e(o[1]));
  // ---- FOR-GENERATE home (the law's site) --------------------------------
  for (genvar i = 0; i < 2; i++) begin : g_for
    leafV5 #(.W(BW)) c0 (.a(bus[0        +: BW]), .b(bus[0        +: BW]), .e(o[2]));
    leafV5 #(.W(BW)) c1 (.a(bus[1        +: BW]), .b(bus[15       -: BW]), .e(o[3]));
    leafV5 #(.W(BW)) c2 (.a(bus[i        +: BW]), .b(bus[i*4      +: BW]), .e(o[4]));
    leafV5 #(.W(BW)) c3 (.a(bus[32'd0    +: BW]), .b(bus[32'd1    +: BW]), .e(o[5]));
    leafV5 #(.W(BW)) c4 (.a(bus['h0      +: BW]), .b(bus['d1      +: BW]), .e(o[6]));
    leafV5 #(.W(BW)) c5 (.a(bus[4'd0     +: BW]), .b(bus[8'h01    +: BW]), .e(o[7]));
    leafV5 #(.W(BW)) c6 (.a(bus[PZ       +: BW]), .b(bus[PONE     +: BW]), .e(o[8]));
    leafV5 #(.W(BW)) c7 (.a(bus[PH       +: BW]), .b(bus[BW-BW    +: BW]), .e(o[9]));
    leafV5 #(.W(BW)) c8 (.a(bus[0        +: 4 ]), .b(bus[0        +: 32'd4]), .e(o[10]));
    leafV5 #(.W(BW)) c9 (.a(bus[(0)      +: BW]), .b(bus[0+0      +: BW]), .e(o[11]));
    leafV5 #(.W(BW)) ca (.a(bus[i+0      +: BW]), .b(bus[8        +: BW]), .e(o[12]));
  end
  // ---- IF-GENERATE home ---------------------------------------------------
  if (BW != 0) begin : g_if
    localparam int i0 = 2;
    leafV5 #(.W(BW)) h0 (.a(bus[0     +: BW]), .b(bus[0  +: BW]), .e(o[13]));
    leafV5 #(.W(BW)) h1 (.a(bus[32'd0 +: BW]), .b(bus[i0 +: BW]), .e(o[14]));
  end
  assign o[15] = 1'b0;
endmodule

module topV5(input [31:0] bus, output [15:0] o1, output [15:0] o2, output [15:0] o3);
  midV5 #(.BW(4)) u_a (bus, o1);
  midV5 #(.BW(2)) u_b (bus, o2);
  midV5 #(.BW(8)) u_c (bus, o3);
endmodule
