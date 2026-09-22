// r11v94 BREAK arm x5 — WHICH initializer shapes make GOLDEN render the
// package constant as a BINARY const with NO typespec.  The landed decline
// reads OUR const type (`have87 == vpiBinaryConst`), which is the `'b` leaf
// alone; a CONCATENATION is golden-binary while we write UINT, so the decline
// misses it.  This arm asks how wide that class is.
package x5p;
  typedef struct packed {
    logic [23:0] bail; logic [23:0] a; logic [23:0] b; logic [23:0] c;
    logic [23:0] d;    logic [23:0] e; logic [23:0] f; logic [23:0] g;
  } t;
  localparam signed PCD = {4'd1, 4'd2};      // concat of DECIMAL leaves
  localparam signed PCH = {4'h1, 4'h2};      // concat of HEX leaves
  localparam signed PCB = {4'b0001, 4'b0010};// concat of BINARY leaves
  localparam signed PRP = {2{4'd3}};         // a REPLICATION
  localparam signed PBL = 8'b1010;           // the `'b` LEAF (landed decline)
  localparam signed PCN = {4'd1, 4'd2} + 0;  // a concat under an operation
  localparam signed PCU = {4'd1, 4'd2};      // repeated, read by a SIGNED hop
  localparam signed PHX = 8'h1A;             // the HEX control (has a ts)
endpackage
module x5_binface94v;
  localparam logic [7:0]         N1 = x5p::PCD;
  localparam logic [7:0]         N2 = x5p::PCH;
  localparam logic [7:0]         N3 = x5p::PCB;
  localparam logic [7:0]         N4 = x5p::PRP;
  localparam logic [7:0]         N5 = x5p::PBL;
  localparam logic [7:0]         N6 = x5p::PCN;
  localparam logic signed [15:0] N7 = x5p::PCU;
  localparam logic [7:0]         N8 = x5p::PHX;
  localparam x5p::t A = '{bail: 8'hxA, a: N1, b: N2, c: N3, d: N4,
                          e: N5, f: N6, g: N7};
  localparam x5p::t B = '{bail: 8'hxA, a: N8, b: N1, c: N2, d: N3,
                          e: N4, f: N5, g: N6};
  x5_sink #(.R(A)) s1();
  x5_sink #(.R(B)) s2();
endmodule
module x5_sink #(parameter x5p::t R = '{default: 0}) (output logic [23:0] o);
  assign o = R.a;
endmodule
