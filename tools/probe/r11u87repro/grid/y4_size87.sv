// r11u87 arm y4 — THE SIZE TABLE.  `adjustSize`
// (CompileHelper.cpp:4086-4088) keeps a `vpiDecConst`'s ORIGINAL width and
// re-sizes every other const type to `Bits(declared type)`, and the store the
// module route reads is `fromVpiValue(c->VpiValue(), c->VpiSize())`.  So a
// `'d` leaf is golden the LITERAL's written width whatever the declaration
// says, and an `'o` leaf is golden the DECLARED width.  MODULE-homed hops,
// 24-bit members, operand 0 a guaranteed bail.
package y4p;
  typedef struct packed {
    logic [23:0] bail; logic [23:0] a; logic [23:0] b; logic [23:0] c;
    logic [23:0] d;    logic [23:0] e; logic [23:0] f; logic [23:0] g;
  } t;
endpackage
module y4_size87;
  localparam int          YI8  = 8'd5;      // 'd:  literal 8  vs declared 32
  localparam bit [31:0]   YB8  = 8'd5;      // 'd:  literal 8  vs declared 32
  localparam logic [3:0]  YL32 = 32'd5;     // 'd:  literal 32 vs declared 4
  localparam int          YUN  = 'd5;       // 'd unsized: the producer's -1
  localparam int          YOO  = 16'o17;    // 'o:  declared 32
  localparam bit [7:0]    YO8  = 16'o777;   // 'o:  declared 8
  localparam int          YPL  = 5;         // plain decimal, declared 32
  localparam logic [95:0] YW   = 96'd12;    // past the word: the clone route
  localparam int          YC1  = 16'd5;
  localparam int          YC2  = YC1;       // a depth-2 chain, both declared
  localparam bit [7:0]    YT8  = 16'd300;   // the truncating declaration
  localparam shortint     YTS  = 32'd70000;
  localparam y4p::t A = '{bail: 8'hxA, a: YI8, b: YB8, c: YL32, d: YUN,
                          e: YOO, f: YO8, g: YPL};
  localparam y4p::t B = '{bail: 8'hxA, a: YW, b: YC2, c: YT8, d: YTS,
                          e: YI8, f: YL32, g: YOO};
  y4_sink #(.R(A)) s1();
  y4_sink #(.R(B)) s2();
endmodule
module y4_sink #(parameter y4p::t R = '{default: 0}) (output logic [23:0] o);
  assign o = R.a;
endmodule
