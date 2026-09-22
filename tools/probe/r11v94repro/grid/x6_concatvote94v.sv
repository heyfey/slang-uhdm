// r11v94 arm x6 — THE FIX'S OWN GRID.  A kind-2 (implicit + signing/dimension)
// package declaration whose initializer CONTAINS a concatenation leaves the
// package's elaborated constant BARE, so the clone carries nothing and the
// READER's declaration votes — the opposite of every other kind-2 shape.  The
// arm holds both faces (a signed package read by an unsigned hop, where golden
// writes NO typespec, and an unsigned package read by a SIGNED hop, where
// golden writes the READER's), the nesting depths, the chain, and the kind-1
// and plain-literal controls that must not move.
package x6p;
  typedef struct packed {
    logic [23:0] bail; logic [23:0] a; logic [23:0] b; logic [23:0] c;
    logic [23:0] d;    logic [23:0] e; logic [23:0] f; logic [23:0] g;
  } t;
  localparam signed        PCD2 = {4'd1, 4'd2};
  localparam signed        PCN2 = {4'd1, 4'd2} + 0;
  localparam unsigned      PCU2 = {4'd1, 4'd2};
  localparam signed        PCC  = PCD2;             // a CHAIN over a concat
  localparam int           JC   = {4'd1, 4'd2};     // kind 1 control
  localparam signed        PTC  = 1 ? {4'd1,4'd2} : 8'd0;
  localparam signed        PSC  = {4'd1, 4'd2} >> 1;
  localparam signed        PLIT = 8'd18;            // the plain-literal control
endpackage
module x6_concatvote94v;
  localparam logic [7:0]         O1 = x6p::PCD2;
  localparam logic signed [15:0] O2 = x6p::PCD2;
  localparam logic signed [15:0] O3 = x6p::PCU2;
  localparam logic [7:0]         O4 = x6p::PCN2;
  localparam logic [7:0]         O5 = x6p::PCC;
  localparam logic [7:0]         O6 = x6p::JC;
  localparam logic [7:0]         O7 = x6p::PTC;
  localparam logic [7:0]         O8 = x6p::PSC;
  localparam logic [7:0]         O9 = x6p::PLIT;
  localparam x6p::t A = '{bail: 8'hxA, a: O1, b: O2, c: O3, d: O4,
                          e: O5, f: O6, g: O7};
  localparam x6p::t B = '{bail: 8'hxA, a: O8, b: O9, c: O1, d: O2,
                          e: O3, f: O4, g: O5};
  x6_sink #(.R(A)) s1();
  x6_sink #(.R(B)) s2();
endmodule
module x6_sink #(parameter x6p::t R = '{default: 0}) (output logic [23:0] o);
  assign o = R.a;
endmodule
