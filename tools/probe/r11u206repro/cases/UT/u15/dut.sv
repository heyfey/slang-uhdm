// § unitClassTdEndAtInitIfcPrg206
virtual class obj; endclass
class cfg#(type T=int, type T2=int);
endclass
typedef cfg#(obj, string) m_misc;
interface bbb ();
  m_misc a = new;
endinterface
interface aaa ();
  m_misc c =
     new;
endinterface
module top ();
  aaa i ();
  bbb j ();
endmodule
