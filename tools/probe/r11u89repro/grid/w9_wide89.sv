// r11u89 arm w9 — THE MODULE ROUTE ACROSS THE 64-BIT BOUNDARY.  The package
// road guards the store with `if (size <= 64)` (`CompileHelper.cpp:3770`); the
// MODULE road (`DesignElaboration.cpp:2645`) has no such guard and calls
// `instance->setValue` unconditionally.  `fromVpiValue` (ExprBuilder.cpp:978+)
// parses the digits through `parseInt64`/`parseUint64` and calls
// `set(v, Type, size)` with the CONSTANT's size, whatever it is.  Widths
// across 64 / 65 / 96 / 128 in a MODULE beside the same widths in a PACKAGE.
package w9p;
  typedef struct packed {
    logic [23:0] bail; logic [23:0] a; logic [23:0] b; logic [23:0] c;
    logic [23:0] d;    logic [23:0] e; logic [23:0] f; logic [23:0] g;
  } t;
  // the PACKAGE twins — the landed fence's own positive control
  localparam logic [95:0]  PW96 = 96'd12;
  localparam logic [64:0]  PW65 = 65'd3;
  localparam logic [127:0] PW128 = 128'd21;
  localparam logic [95:0]  PO96 = 96'o17;
endpackage
module w9_wide89;
  localparam logic [63:0]  YW64  = 64'd12;    // inside the word
  localparam logic [64:0]  YW65  = 65'd3;     // one bit past
  localparam logic [95:0]  YW96  = 96'd12;    // the brief's cell
  localparam logic [127:0] YW128 = 128'd21;
  localparam logic [95:0]  YO96  = 96'o17;    // the octal face, past 64
  localparam logic [95:0]  YH96  = 96'h5;     // the hex face, past 64
  localparam int signed    YS96  = 96'd12;    // a signed declaration, past 64
  // a value that does NOT fit a 64-bit word, written 96 bits wide
  localparam logic [95:0]  YBIG  = 96'd79228162514264337593543950335;
  localparam w9p::t A = '{bail: 8'hxA, a: YW64, b: YW65, c: YW96, d: YW128,
                          e: YO96, f: YH96, g: YS96};
  localparam w9p::t B = '{bail: 8'hxA, a: YBIG, b: w9p::PW96, c: w9p::PW65,
                          d: w9p::PW128, e: w9p::PO96, f: YW96, g: YW65};
  w9_sink #(.R(A)) s1();
  w9_sink #(.R(B)) s2();
  // an OVERRIDDEN wide hop — the override road has no fence either, and its
  // width is the OVERRIDE literal's
  w9_mid #(.OW(96'd7), .ON(128'o21)) m1();
  w9_mid                             m2();
endmodule
module w9_mid #(parameter logic [95:0]  OW = 96'd1,
                parameter logic [127:0] ON = 128'o3) ();
  localparam w9p::t C = '{bail: 8'hxA, a: OW, b: ON, c: OW, d: ON,
                          e: OW, f: ON, g: OW};
  w9_sink #(.R(C)) s3();
endmodule
module w9_sink #(parameter w9p::t R = '{default: 0}) (output logic [23:0] o);
  assign o = R.a;
endmodule
