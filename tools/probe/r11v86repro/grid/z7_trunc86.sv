// VERIFIER arm z7 — A DECLARED WIDTH THAT TRUNCATES THE LITERAL.  The law
// writes the digits `red72Int64` reads off OUR source expression.  A parameter
// whose DECLARED type is narrower than its literal holds the TRUNCATED value in
// the producer's store, so if our reader answers the literal's digits instead
// of the parameter's value the law writes digits golden never had.
package z7p;
  typedef struct packed {
    logic [23:0] bail; logic [23:0] a; logic [23:0] b; logic [23:0] c;
    logic [23:0] d;    logic [23:0] e; logic [23:0] f; logic [23:0] g;
  } t;
endpackage
module z7_trunc86;
  localparam bit  [7:0]  ZT8  = 16'd300;      // 300 & 0xFF = 44
  localparam bit  [3:0]  ZT4  = 16'd300;      // 300 & 0xF  = 12
  localparam byte        ZTB  = 16'd300;      // 8-bit signed
  localparam bit  [7:0]  ZTO  = 16'o777;      // 511 & 0xFF = 255
  localparam bit  [3:0]  ZTO4 = 16'o17;       // 15
  localparam shortint    ZTS  = 32'd70000;    // 70000 & 0xFFFF = 4464
  localparam bit  [7:0]  ZTN  = 8'd200;       // no truncation, control
  localparam logic [7:0] ZTL  = 16'd300;
  localparam z7p::t Z = '{bail: 8'hxA, a: ZT8, b: ZT4, c: ZTB, d: ZTO,
                          e: ZTO4, f: ZTS, g: ZTN};
  localparam z7p::t Z2 = '{bail: 8'hxA, a: ZTL, b: ZT8, c: ZTO, d: ZTS,
                           e: ZT4, f: ZTB, g: ZTO4};
  z7_sink #(.R(Z)) s1();
  z7_sink #(.R(Z2)) s2();
endmodule
module z7_sink #(parameter z7p::t R = '{default: 0}) (output logic [23:0] o);
  assign o = R.a;
endmodule
