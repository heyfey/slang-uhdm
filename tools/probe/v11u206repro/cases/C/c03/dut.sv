// § unitClassTdEndAtInitIfcPrg206
virtual class obj; endclass
class cfg#(type T=int, type T2=int);
endclass
typedef cfg#(obj, string) m_misc;
interface ifc ();
  m_misc a = new;
  m_misc b;
  modport mp (input a);
endinterface
program prg (ifc.mp p);
  m_misc c =
    new;
endprogram
module top ();
  ifc i ();
  prg q (.p(i));
endmodule
