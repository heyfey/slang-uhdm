// § unitClassTdEndAtInitIfcPrg206
virtual class obj; endclass
class cfg#(type T=int, type T2=int);
endclass
typedef cfg#(obj, string) m_misc;
program zp ();
  m_misc c = new;
endprogram
interface ifc ();
  m_misc a =
      new;
endinterface
module top ();
  ifc i ();
  zp p ();
endmodule
