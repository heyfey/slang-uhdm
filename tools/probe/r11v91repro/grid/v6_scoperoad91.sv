// r11v91 BREAK arm v6 — THE SCOPED-NAME GATE'S OWN EDGES, and the no-typespec
// package hop at a width the reader does not share.  A MACRO-expanded scoped
// read, a PARAMETER PORT default, a generate-FOR home, a CLASS-scoped read
// (whose home is not a package at all) and a hierarchical read.
`define PKI v6p::MI
package v6p;
  typedef struct packed {
    logic [23:0] bail; logic [23:0] a; logic [23:0] b; logic [23:0] c;
    logic [23:0] d;    logic [23:0] e; logic [23:0] f; logic [23:0] g;
  } t;
  localparam int MI   = 16'd5;
  localparam     MIMP = 8'd5;      // implicit, no typespec on the clone
  localparam logic [15:0] MU = 16'd6;
endpackage
class v6c #(parameter int CI = 16'd7);
endclass
module v6_scoperoad91;
  localparam logic [7:0]         N1 = `PKI;          // MACRO-expanded scope
  localparam logic signed [31:0] N2 = v6p::MIMP;     // no-ts pkg, WIDER reader
  localparam logic [3:0]         N3 = v6p::MIMP;     // no-ts pkg, NARROWER
  localparam logic signed [7:0]  N4 = v6p::MU;       // signed reader, ts pkg
  localparam v6p::t A = '{bail: 8'hxA, a: N1, b: N2, c: N3, d: N4,
                          e: N1, f: N2, g: N3};
  v6_sink #(.R(A)) s1();
  for (genvar i = 0; i < 1; i++) begin : gf
    localparam logic [7:0] P1 = v6p::MI;
    localparam logic signed [31:0] P2 = v6p::MIMP;
    localparam v6p::t B = '{bail: 8'hxA, a: P1, b: P2, c: P1, d: P2,
                            e: P1, f: P2, g: P1};
    v6_sink #(.R(B)) s2();
  end
endmodule
module v6_sink #(parameter v6p::t R = '{default: 0}) (output logic [23:0] o);
  assign o = R.a;
endmodule
module v6_port #(parameter logic [7:0] Q1 = v6p::MI,
                 parameter logic signed [31:0] Q2 = v6p::MIMP) ();
  localparam v6p::t C = '{bail: 8'hxA, a: Q1, b: Q2, c: Q1, d: Q2,
                          e: Q1, f: Q2, g: Q1};
  v6_sink #(.R(C)) s3();
endmodule
