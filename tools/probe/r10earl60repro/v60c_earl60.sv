// r10earl60 arm C — the fences arm B and arm A leave open: a name COLLISION with
// NO import at all, a PARAMETER PORT default vs an instantiation OVERRIDE, a
// GENERATE-scope localparam, a CHAINED reference, and a package that references
// another package (the `inPackage` fence).
package p2;
  localparam int          A8  = 8;
  localparam logic [11:0] B12 = 12'h380;
endpackage

package p3;                       // package -> package: the inPackage fence
  localparam int Z = p2::A8;
endpackage

module s_coll_noimp ();           // local name COLLIDES, NO import anywhere
  localparam int A8 = p2::A8;
endmodule

module s_portdef #(
  parameter int PD = p2::A8       // PORT parameter DEFAULT from a package
) ();
  logic [PD-1:0] d;
endmodule

module s_portov #(
  parameter int PO = 1            // PORT parameter OVERRIDDEN from a package
) ();
  logic [PO-1:0] d;
endmodule

module s_gen ();
  for (genvar i = 0; i < 2; i++) begin : g
    localparam int gp = p2::A8;   // GEN-scope localparam from a package
    logic [gp-1:0] d;
  end
endmodule

module s_chain ();
  localparam int c1 = p2::A8;     // direct
  localparam int c2 = c1;         // chained through a local param
endmodule

module s_neg ();
  localparam int n1 = 8;          // literal: must NOT take a package typespec
  localparam int n2 = p2::A8 + 0; // operation: must NOT take a package typespec
  localparam int n3 = p3::Z;      // ref to a param that itself came from p2
endmodule

module a1 ();
  s_coll_noimp u0 ();
  s_portdef    u1 ();
  s_portov #(.PO(p2::A8)) u2 ();
  s_gen        u3 ();
  s_chain      u4 ();
  s_neg        u5 ();
endmodule
