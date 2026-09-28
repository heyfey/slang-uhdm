// § unitClassTdEndAtInitIfcPrg206
virtual class obj; endclass
class cfg#(type T=int, type T2=int);
endclass
typedef cfg#(obj, string) m_misc;
interface ifc ();
`include "decl.svh"
endinterface
program prg ();
`include "decl.svh"
endprogram
module top ();
  ifc i ();
  prg q ();
endmodule
