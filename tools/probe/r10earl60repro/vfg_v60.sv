// v60 VERIFIER arm G — the scopes the other arms do not reach: a CLASS
// parameter defaulted from a package, a PROGRAM body, a package parameter
// used through a TYPEDEF'd ref, and a module instantiated inside an
// INTERFACE.  All take the package member by explicit scope.
package gp;
  localparam int          GA = 8;
  localparam logic [11:0] GB = 12'h380;
  localparam              GU = 6;            // PLAIN UNTYPED: no vpiInstance
endpackage

class c_par #(parameter int CP = gp::GA);
  int q = CP;
endclass

program s_prog ();
  localparam int pr_p = gp::GA;
  localparam     pr_u = gp::GU;
  initial $display(pr_p, pr_u);
endprogram

interface s_ifm ();
  localparam int im_p = gp::GA;
  localparam int im_u = gp::GU;              // typed local, UNTYPED source
endinterface

module s_use ();
  localparam int         w1 = gp::GA;
  localparam int         w2 = gp::GU;        // typed local, UNTYPED source
  localparam logic[11:0] w3 = gp::GB;
  c_par #(.CP(gp::GA)) h;
  s_ifm u_if ();
  logic [w1-1:0] d;
endmodule

module a1 ();
  s_use  u0 ();
  s_prog u1 ();
endmodule
