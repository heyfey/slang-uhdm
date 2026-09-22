// r11u87 arm y8 — THE PATTERN THAT DOES NOT BAIL.  § patBailStopsMemberStamp68
// (r11u68): `expandPatternAssignment` stamps the MEMBER width on every operand
// and stops at the first one its reduce refuses, so a pattern with no refusing
// operand has EVERY operand re-sized to the member width — the store's own
// width is gone.  Here the same two signed hops are read once from a pattern
// with NO bail and once from a pattern whose first operand is the usual
// unknown-digit bail, so the two answers stand side by side.
package y8p;
  typedef struct packed {
    logic [23:0] p; logic [23:0] q; logic [23:0] r;
  } t3;
endpackage
module y8_nob87;
  localparam int            YIN = 16'd5;
  localparam signed [15:0]  YSG = 16'o17;
  localparam                YDU = 16'd5;
  localparam y8p::t3 N = '{p: YIN, q: YSG, r: YDU};
  localparam y8p::t3 D = '{default: YIN};
  localparam y8p::t3 B = '{p: 8'hxA, q: YIN, r: YSG};
  y8_s3 #(.R(N)) s1();
  y8_s3 #(.R(B)) s2();
endmodule
module y8_s3 #(parameter y8p::t3 R = '{default: 0}) (output logic [23:0] o);
  assign o = R.p;
endmodule
