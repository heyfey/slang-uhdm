// r10v64 ARM 6 — the rawText-ACROSS-MACRO-BUFFERS trap for the F-B1 fence
// (uvm94's lesson: rawText inside a macro BODY comes back EMPTY, which reads
// as "no apostrophe" = BARE).  Both spellings supplied through a macro.
// MEASUREMENT ONLY.
`define ZERO_BARE  0
`define ZERO_SIZED 32'd0
`define ONE_SIZED  8'h01
`define SEL_BARE(b,w)  bus[`ZERO_BARE  +: w]
`define SEL_SIZED(b,w) bus[`ZERO_SIZED +: w]

module leafV6 #(parameter int W = 4)(input [W-1:0] a, input [W-1:0] b, output e);
  assign e = |a ^ |b;
endmodule

module midV6 #(parameter int BW = 4)(input [31:0] bus, output [7:0] o);
  for (genvar i = 0; i < 2; i++) begin : g_for
    leafV6 #(.W(BW)) d0 (.a(bus[`ZERO_BARE  +: BW]), .b(bus[`ZERO_BARE  +: BW]), .e(o[0]));
    leafV6 #(.W(BW)) d1 (.a(bus[`ZERO_SIZED +: BW]), .b(bus[`ZERO_SIZED +: BW]), .e(o[1]));
    leafV6 #(.W(BW)) d2 (.a(bus[`ONE_SIZED  +: BW]), .b(bus[1           +: BW]), .e(o[2]));
    leafV6 #(.W(BW)) d3 (.a(`SEL_BARE(bus,BW)),      .b(`SEL_BARE(bus,BW)),      .e(o[3]));
    leafV6 #(.W(BW)) d4 (.a(`SEL_SIZED(bus,BW)),     .b(`SEL_SIZED(bus,BW)),     .e(o[4]));
  end
  assign o[7:5] = 3'b0;
endmodule

module topV6(input [31:0] bus, output [7:0] oa, output [7:0] ob);
  midV6 #(.BW(4)) u_a (bus, oa);
  midV6 #(.BW(2)) u_b (bus, ob);
endmodule
