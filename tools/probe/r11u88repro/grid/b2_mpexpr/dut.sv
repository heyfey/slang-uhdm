// v11u83 b2 -- LAW A BREAK: a modport EXPRESSION port binds by NAME over
// netMap (pendingModportExprRefs).  An imported package namesake now sits in
// that map.  Does the expression port still bind the interface's own member?
package pk;
  logic [7:0] mv;
endpackage

interface ifc ();
  import pk::*;
  logic [15:0] mv;
  logic [15:0] own;
  modport mp (output .out(mv), input own);
endinterface

module sub (ifc.mp p, output logic [31:0] o);
  assign o = {16'd0, p.own};
endmodule

module dut (output logic [31:0] o);
  ifc u_if ();
  sub u_sub (.p(u_if.mp), .o(o));
endmodule
