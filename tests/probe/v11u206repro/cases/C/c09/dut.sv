// § unitClassTdEndAtInitIfcPrg206
`define DECL(n) m_misc n = new;
virtual class obj; endclass
class cfg#(type T=int, type T2=int);
endclass
typedef cfg#(obj, string) m_misc;
interface ifc ();
  `DECL(a)
endinterface
program prg ();
  m_misc c = new;
endprogram
module top ();
  ifc i ();
  prg q ();
endmodule
