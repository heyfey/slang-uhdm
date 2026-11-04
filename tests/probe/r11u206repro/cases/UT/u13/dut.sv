// § unitClassTdEndAtInitIfcPrg206
virtual class obj; endclass
class cfg#(type T=int, type T2=int);
endclass
typedef cfg#(obj, string) m_misc;
interface aaa ();
  m_misc a = new;
endinterface
program bbb ();
  m_misc c =
     new;
endprogram
module top ();
  aaa i ();
  bbb p ();
endmodule
