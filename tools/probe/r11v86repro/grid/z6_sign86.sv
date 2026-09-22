// VERIFIER arm z6 — SIGNEDNESS AGAINST THE OCTAL ARM.  The law maps every `'o`
// leaf to `vpiUIntConst`/`UINT:`.  `Value::Type::Integer` renders `INT:`, so if
// a SIGNED octal parameter stores Integer the law writes UINT: on a golden
// INT: cell — a MOVED-WRONG the landed grid never tested (`m2_enc86` has one
// `16'o5`, unsigned, and `m5_bnd86`'s two are unsigned too).
package z6p;
  typedef struct packed {
    logic [23:0] bail; logic [23:0] a; logic [23:0] b; logic [23:0] c;
    logic [23:0] d;    logic [23:0] e; logic [23:0] f; logic [23:0] g;
  } t;
endpackage
module z6_sign86;
  localparam signed [15:0] ZSO = 16'o5;
  localparam                ZSO2 = 16'so17;
  localparam signed [15:0] ZSD = 16'd5;
  localparam                ZSD2 = 16'sd7;
  localparam int signed     ZIS = 16'o17;
  localparam logic signed [15:0] ZLO = 16'o17;
  localparam                ZUO = 16'o17;
  localparam                ZUD = 16'd17;
  localparam z6p::t Z = '{bail: 8'hxA, a: ZSO, b: ZSO2, c: ZSD, d: ZSD2,
                          e: ZIS, f: ZLO, g: ZUO};
  localparam z6p::t Z2 = '{bail: 8'hxA, a: ZUD, b: ZUO, c: signed'(ZSO),
                           d: unsigned'(ZSD), e: $signed(ZUO), f: $unsigned(ZUD),
                           g: ZSO};
  z6_sink #(.R(Z)) s1();
  z6_sink #(.R(Z2)) s2();
endmodule
module z6_sink #(parameter z6p::t R = '{default: 0}) (output logic [23:0] o);
  assign o = R.a;
endmodule
