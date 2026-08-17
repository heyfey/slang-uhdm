// r10earl54 GRID a2 — THE BOUNDARY GRID.  a1 established the law and its two
// context counterexamples (cont-assign, procedural); a2 asks where the
// CONNECTION path itself can put a nested replication, so that "only cells the
// law names may move" is a measurement rather than a hope.
//
// Every cell is a nested, constant-body replication inside a port-connection
// actual, varying the SHAPE OF THE CONNECTION rather than the expression.
package pk2_54;
  parameter int N = 4;
  typedef struct packed { logic [3:0] hi; logic [3:0] lo; } pair_t;
  // The clkmgr_pkg shape: the replication lives in the PARAMETER'S INITIALIZER,
  // not in the connection expression.  Earlgrey's ONE non-tlul mover.
  parameter pair_t PAIR_DEF = '{ hi: {4{1'b1}}, lo: 4'h0 };
endpackage

module sink2_54 #(parameter int WD = 8) (
  input  [WD-1:0] a,
  output [WD-1:0] o
);
  assign o = ~a;
endmodule

module sinkp_54 (input pk2_54::pair_t p, output logic [7:0] o);
  assign o = p.hi ^ p.lo;
endmodule

interface ifc2_54;
  logic [7:0] bus;
endinterface

module mid2_54 (ifc2_54 ifp, input logic [7:0] d, output logic [7:0] o);
  logic [7:0] w;
  sink2_54 #(.WD(8)) u_in_mid (.a({d[3:0], {4{1'b1}}}), .o(w));
  assign o = w ^ ifp.bus;
endmodule

module a2_earl54 (
  input  logic       sel,
  input  logic [7:0] d,
  output logic [7:0] q
);
  ifc2_54 theif();
  logic [7:0] w1, w2, w3, w4, w5, w6, w7, w8;

  // B1 — PARAMETER-INITIALIZER replication reached through a package param
  //      actual (the clkmgr cell).  The replication is NOT in the conn expr.
  sinkp_54 u_pinit (.p(pk2_54::PAIR_DEF), .o(w1));

  // B2 — inside a GENERATE scope.
  for (genvar gi = 0; gi < 2; gi++) begin : gen_b2
    sink2_54 #(.WD(8)) u_gen (.a({sel ? d[3:0] : {4{1'b0}}, 4'h1}), .o());
  end

  // B3 — replication count is the GENVAR (per-instance value).
  for (genvar gj = 1; gj < 3; gj++) begin : gen_b3
    sink2_54 #(.WD(8)) u_gv (.a({sel ? d[7-gj:0] : {gj{1'b1}}, 4'h2}), .o());
  end

  // B4 — INSTANCE ARRAY: one written connection, several elements.
  sink2_54 #(.WD(8)) u_arr [0:1] (.a({sel ? d[3:0] : {4{1'b1}}, 4'h3}), .o());

  // B5 — OUTPUT direction port with an expression actual is illegal, so the
  //      nearest legal neighbour: the replication in an INPUT of a module that
  //      also drives an output through an interface port.
  mid2_54 u_mid (.ifp(theif), .d(d), .o(w2));

  // B6 — replication under a SYSTEM FUNCTION CALL in the actual.
  sink2_54 #(.WD(8)) u_sys (.a({sel ? d[3:0] : 4'($bits({4{1'b0}})), 4'h4}),
                            .o(w3));

  // B7 — replication nested inside ANOTHER replication's body, itself nested.
  sink2_54 #(.WD(8)) u_rr (.a({sel ? d[3:0] : {2{{2{1'b1}}}}, 4'h5}), .o(w4));

  // B8 — NON-CONSTANT body under a parameter count (the Earlgrey rstmgr KEEP
  //      cell's shape).  MUST NOT FOLD, on either side.
  sink2_54 #(.WD(8)) u_keep (.a({sel ? d[3:0] : {pk2_54::N{d[0]}}}), .o(w5));

  // B9 — replication inside an ASSIGNMENT PATTERN written AT the connection.
  sinkp_54 u_pat (.p('{ hi: {4{1'b1}}, lo: 4'h6 }), .o(w6));

  // B10 — a replication in a NAMED PARAMETER OVERRIDE expression.
  sink2_54 #(.WD($bits({8{1'b0}}))) u_povr (.a({d[3:0], 4'h7}), .o(w7));

  // B11 — replication in a CONDITIONAL-GENERATE branch's connection.
  if (pk2_54::N == 4) begin : gen_b11
    sink2_54 #(.WD(8)) u_cif (.a({sel ? d[3:0] : {4{1'b0}}, 4'h8}), .o(w8));
  end

  assign q = w1 ^ w2 ^ w3 ^ w4 ^ w5 ^ w6 ^ w7 ^ w8;
endmodule
