// r11v96 VERIFIER arm v7 — LAW B ON THE PATTERN ROAD.  `red72Int64` is read by
// the `'{...}` pattern laws (the bail index, the store size, the hop's own
// refusal) as well as by r11u96's net-decl-assign gate, so a written-digits
// read past 2^31 reaches those laws too.  This arm puts big unsized decimals
// into package hops and reads them through a packed-struct pattern.
package v7p;
  typedef struct packed {
    logic [39:0] bail; logic [39:0] a; logic [39:0] b; logic [39:0] c;
    logic [39:0] d;    logic [39:0] e; logic [39:0] f; logic [39:0] g;
  } t;
  localparam longint       H1 = 4294967296 - 0;
  localparam longint       H2 = 8589934592 / 2;
  localparam longint       H3 = 2147483648 * 1;
  localparam longint       H4 = -4294967296;
  localparam longint       H5 = 4294967296 + 1;     // the `+` arm, no mint
  localparam longint       H6 = 1073741824 - 0;     // the control, fits
  localparam int           H7 = 40'd4294967296 - 0; // a BASED leaf control
  localparam longint       H8 = 4294967296;         // no operator at all
endpackage
module v7_bigpat96v;
  localparam v7p::t A = '{bail: 8'hxA, a: v7p::H1, b: v7p::H2, c: v7p::H3,
                          d: v7p::H4, e: v7p::H5, f: v7p::H6, g: v7p::H7};
  localparam v7p::t B = '{bail: 8'hxA, a: v7p::H8, b: v7p::H1, c: v7p::H6,
                          d: v7p::H2, e: v7p::H3, f: v7p::H7, g: v7p::H5};
  v7_sink #(.R(A)) s1();
  v7_sink #(.R(B)) s2();
endmodule
module v7_sink #(parameter v7p::t R = '{default: 0}) (output logic [39:0] o);
  assign o = R.a;
endmodule
