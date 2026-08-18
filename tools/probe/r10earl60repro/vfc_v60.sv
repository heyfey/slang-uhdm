// v60 VERIFIER arm C — OVERRIDE / DEFAULT / CHAIN, and the SAME module
// instantiated twice with DIFFERENT package sources.  This is the shape the
// implementer's stated law fences ("an instantiation OVERRIDE keeps the
// declaring scope's own typespec") but which the CODE has no `overridden`
// test for.
package pa;
  localparam int          AA = 8;
  localparam logic [11:0] AB = 12'h380;
endpackage
package pb;
  localparam int          BA = 9;
  localparam logic [11:0] BB = 12'h381;
endpackage

module s_port #(
  parameter int          PD = pa::AA,   // PORT param, DEFAULT from a package
  parameter logic [11:0] PV = pa::AB
) ();
  localparam int lp = PD;               // chained through the port param
  logic [PD-1:0] d;
  logic [11:0]   e = PV;
endmodule

module s_povr #(
  parameter int          QD = 1,
  parameter logic [11:0] QV = 12'h0
) ();
  logic [QD-1:0] d;
  logic [11:0]   e = QV;
endmodule

module s_defp ();
  localparam int dp = pa::AA;
  logic [dp-1:0] d;
endmodule

module a1 ();
  s_port u_pd ();                        // default USED
  s_port #(.PD(pb::BA), .PV(pb::BB)) u_po ();   // default OVERRIDDEN from pkg B
  s_port #(.PD(7))      u_pl ();         // default overridden by a LITERAL
  s_povr #(.QD(pa::AA), .QV(pa::AB)) u_q0 ();   // override from pkg A
  s_povr #(.QD(pb::BA), .QV(pb::BB)) u_q1 ();   // SAME module, DIFFERENT pkg
  s_defp u_d0 ();
  s_defp u_d1 ();                        // two instances, one module
endmodule
