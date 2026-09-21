// r11v73 ADVERSARIAL arm x9b — THE CAST FACES OF LAW D.
// `red73MintsUntypedInt` answers TRUE for EVERY `Conversion` and the gate
// `red72Int64(...) != Refuses` is open on all of them.  The implementer
// measured ONE cast (`AC = 16'(5)`, golden 32).  Here: a SIGNED cast, an
// UNSIGNED cast and a cast to a TYPEDEF, one hop above.
// (A real, a string, `'0`, `int'(3.7)` and a cast to a user TYPEDEF are NOT here: a struct-pattern
// member taking one makes OUR compile fail with `expression kind: Invalid`,
// and an arm whose compile fails teaches error recovery, not golden.
// `red73MintsUntypedInt` abstains on them by construction anyway.)
package x9;
  localparam            C16 = 16'(5);            // the MEASURED control
  localparam            HC1 = C16;
  localparam            CS  = signed'(16'd5);    // a SIGNED cast
  localparam            HCS = CS;
  localparam            CU  = unsigned'(16'sd5); // an UNSIGNED cast
  localparam            HCU = CU;
  localparam            AD  = 16'd9 + 16'd1;     // control: golden 32
  localparam            HAD = AD;
  localparam int        K   = 6;
  typedef struct packed {
    logic [23:0] bail; // 8'hxA  GUARANTEED BAIL
    logic [23:0] a;    // HC1  control (golden 32)
    logic [23:0] b;    // HCS
    logic [23:0] c;    // HCU
    logic [23:0] d;    // HAD  control (golden 32)
    logic [23:0] e;    // K+1  plain control
  } x9_t;
  localparam x9_t A = '{bail: 8'hxA, a: HC1, b: HCS, c: HCU, d: HAD,
                        e: K+1};
endpackage
module x9c_cast73 #(parameter x9::x9_t CA = x9::A)
                   (output logic [23:0] z0, output logic [23:0] z1,
                    output logic [23:0] z2, output logic [23:0] z3,
                    output logic [23:0] z4, output logic [23:0] z5);
  assign z0 = CA.bail; assign z1 = CA.a; assign z2 = CA.b; assign z3 = CA.c;
  assign z4 = CA.d;    assign z5 = CA.e;
endmodule
