// v11u83 b5 -- LAW A: a MODPORT io_decl over a hoisted namesake, plus the
// interface's own member of the same name.  netMap.find(internal) is
// Symbol-keyed, but the modport's io_decl listing walks the interface's
// members; does the hoist leak an entry into it?
package pk;
  logic [7:0] sig;
  wire  [7:0] wsig;
endpackage

interface ifc ();
  import pk::*;
  logic [15:0] sig;
  logic [15:0] o_own;
  modport mp (input sig, output o_own);
endinterface

module sub (ifc.mp p, output logic [31:0] o);
  assign o = {16'd0, p.sig};
endmodule

module dut (output logic [31:0] o);
  ifc u_if ();
  sub u_sub (.p(u_if.mp), .o(o));
endmodule
