// r10v64 ARM 8 — the HARD rawText trap: literals built by TOKEN PASTING and by
// nested macros, so the base literal's sourceRange crosses macro buffers.  If
// rawText comes back empty the F-B1 fence reads "no apostrophe" = BARE and the
// arm would mint UINT for a SIZED literal.  MEASUREMENT ONLY.
`define W32 32
`define PASTE(n) `W32``'d``n
`define NEST_SIZED `PASTE(0)
`define NEST_BARE  0
`define LVL1 `NEST_BARE
`define LVL2 `LVL1

module leafV8 #(parameter int W = 4)(input [W-1:0] a, input [W-1:0] b, output e);
  assign e = |a ^ |b;
endmodule

module midV8 #(parameter int BW = 4)(input [31:0] bus, output [7:0] o);
  for (genvar i = 0; i < 2; i++) begin : g_for
    leafV8 #(.W(BW)) p0 (.a(bus[`NEST_SIZED +: BW]), .b(bus[`NEST_SIZED +: BW]), .e(o[0]));
    leafV8 #(.W(BW)) p1 (.a(bus[`LVL2       +: BW]), .b(bus[`LVL2       +: BW]), .e(o[1]));
    leafV8 #(.W(BW)) p2 (.a(bus[`PASTE(1)   +: BW]), .b(bus[1           +: BW]), .e(o[2]));
  end
  assign o[7:3] = 5'b0;
endmodule

module topV8(input [31:0] bus, output [7:0] oa, output [7:0] ob);
  midV8 #(.BW(4)) u_a (bus, oa);
  midV8 #(.BW(2)) u_b (bus, ob);
endmodule
