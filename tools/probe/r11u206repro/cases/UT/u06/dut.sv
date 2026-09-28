// § unitClassTdEndAtInitIfcPrg206
virtual class obj; endclass
class cfg#(type T=int, type T2=int);
endclass
typedef cfg#(obj, string) m_misc;
interface ifc ();
  m_misc a = new, c =
      new;
endinterface
program aab ();
  m_misc q;
endprogram
module top ();
  ifc i ();
  aab p ();
endmodule
