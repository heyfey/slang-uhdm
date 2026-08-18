// r10earl64 GRID B — the ELAB re-emission of CONSTANTS inside a port
// High_conn expression, keyed by (home, select shape, literal spelling).
// MEASUREMENT ONLY.
module leafB #(parameter int W = 4) (input [W-1:0] a, input [W-1:0] b,
                                     input [3:0] c, input d, output e);
  assign e = |a ^ |b ^ |c ^ d;
endmodule

module midB #(parameter int BW = 4) (input [7:0] bus, input [7:0] bus2, output [5:0] o);
  // ---- MODULE BODY home -------------------------------------------------
  leafB #(.W(BW)) i_ips   (.a(bus[0 +: BW]), .b(bus[0 +: BW]), .c(bus[3:0]), .d(bus[3]), .e(o[0]));
  leafB #(.W(BW)) i_ps    (.a(bus[BW-1:0]),  .b(bus[3:0]),     .c(bus[3:0]), .d(bus[0]), .e(o[1]));
  leafB #(.W(BW)) i_lit   (.a(4'd0),         .b(8'h0f),        .c({3'b000, 1'b1}), .d(1'b0), .e(o[2]));
  leafB #(.W(BW)) i_ipsz  (.a(bus[32'd0 +: BW]), .b(bus['h0 +: BW]), .c(bus[3:0]), .d(bus[1]), .e(o[3]));
  // ---- FOR-GENERATE home -------------------------------------------------
  for (genvar i = 0; i < 2; i++) begin : g_for
    leafB #(.W(BW)) i_g (.a(bus[0 +: BW]), .b(bus[i*4 +: BW]), .c(bus[3:0]), .d(bus[i]), .e(o[4]));
  end
  // ---- IF-GENERATE home --------------------------------------------------
  if (BW != 0) begin : g_if
    leafB #(.W(BW)) i_h (.a(bus[0 +: BW]), .b(bus2[0 +: BW]), .c(bus[3:0]), .d(bus[2]), .e(o[5]));
  end
endmodule

module topB(input [7:0] bus, input [7:0] bus2, output [5:0] o1, output [5:0] o2);
  midB #(.BW(4)) u_a (bus, bus2, o1);
  midB #(.BW(2)) u_b (bus, bus2, o2);
endmodule
