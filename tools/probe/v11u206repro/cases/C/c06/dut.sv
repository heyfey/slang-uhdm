// § unitClassTdEndAtInitIfcPrg206
virtual class obj; endclass
class cfg#(type T=int, type T2=int);
endclass
typedef cfg#(obj, string) m_misc;
interface ifc ();
  m_misc a = null;
endinterface
program prg ();
  m_misc c = new;
endprogram
module top ();
  ifc i ();
  prg q ();
endmodule
