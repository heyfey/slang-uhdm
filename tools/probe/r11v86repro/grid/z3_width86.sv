// VERIFIER arm z3 — WIDTH AND TRUNCATION.  The law writes the digits
// `red72Int64` reads off OUR source expression.  If the producer's stored
// value (or the pattern's own assignment) TRUNCATES to the member width, the
// law's digits are wrong.  8-bit members with hops far wider than 8 bits, plus
// a 24-bit member fed a value past 2^24, plus the octal digits at width.
package z3p;
  typedef struct packed {
    logic [7:0] bail; logic [7:0] a; logic [7:0] b; logic [7:0] c; logic [7:0] d;
  } t8;
  typedef struct packed {
    logic [23:0] bail; logic [23:0] a; logic [23:0] b; logic [23:0] c;
  } t24;
endpackage
module z3_width86;
  localparam Z300  = 16'd300;
  localparam ZMAX8 = 16'd65535;
  localparam ZO377 = 16'o377;
  localparam ZBIG  = 32'd16777216;
  localparam ZOBIG = 32'o77777777;
  localparam z3p::t8  ZA = '{bail: 8'hxA, a: Z300, b: ZMAX8, c: ZO377, d: 8'd7};
  localparam z3p::t24 ZB = '{bail: 8'hxA, a: ZBIG, b: ZOBIG, c: Z300};
  z3_sink8  #(.R(ZA)) s1();
  z3_sink24 #(.R(ZB)) s2();
endmodule
module z3_sink8 #(parameter z3p::t8 R = '{default: 0}) (output logic [7:0] o);
  assign o = R.a;
endmodule
module z3_sink24 #(parameter z3p::t24 R = '{default: 0}) (output logic [23:0] o);
  assign o = R.a;
endmodule
