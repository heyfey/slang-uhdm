// § unitClassTdEndAtInitIfcPrg206
virtual class obj; endclass
class cfg#(type T=int, type T2=int);
endclass
typedef cfg#(obj, string) m_misc;
program bbb ();
  m_misc c =
     new;
endprogram
interface aaa ();
  m_misc a = new;
endinterface
module top ();
  aaa i ();
  bbb p ();
endmodule
