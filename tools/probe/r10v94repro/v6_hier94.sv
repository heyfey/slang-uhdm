// r10v94 arm v6 -- cast operands that are NOT bare local names: a hierarchical
// reference through an interface instance, a package-scoped variable, a
// modport-qualified signal, an upward reference, and a name that collides with
// a gen-local in a SIBLING gen scope.  MEASUREMENT ONLY.
package pkv6_94;
  logic [7:0] pvar;
  localparam int unsigned PW = 8;
endpackage

interface ifv6_94 ();
  logic [7:0] sig;
  logic [7:0] other;
  assign sig = '0;
  modport mp (input sig, output other);
endinterface

module chv6_94 (
  ifv6_94.mp m_if,
  input  logic [7:0] a_i,
  output logic [7:0] o1,o2,o3,o4
);
  import pkv6_94::*;
  logic [7:0] m_var;
  logic [7:0] sib;
  assign m_var = a_i;
  assign sib   = a_i;

  if (1) begin : gen_h
    // a modport-qualified interface signal under a cast
    assign o1 = 8'(m_if.sig);
    // a package-scoped variable under a cast
    assign o2 = 8'(pkv6_94::pvar);
    // an imported package variable by bare name
    assign o3 = 8'(pvar);
    // a bare module name that ALSO names a gen-local in a SIBLING gen scope
    assign o4 = 8'(sib);
  end
  if (1) begin : gen_sib
    logic [7:0] sib;
    assign sib = a_i;
  end
endmodule

module v6_hier94_top (
  input logic [7:0] a8,
  output logic [7:0] r1,r2,r3,r4
);
  ifv6_94 the_if ();
  chv6_94 u_a (.m_if(the_if.mp), .a_i(a8), .o1(r1),.o2(r2),.o3(r3),.o4(r4));
endmodule
