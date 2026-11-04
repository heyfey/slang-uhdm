// § unitClassTdEndAtInitIfcPrg206
virtual class obj; endclass
class cfg#(type T=int, type T2=int);
endclass
typedef cfg#(obj, string) m_misc;
program aaa ();
  m_misc c =
     new;
endprogram
interface bbb ();
  m_misc a = new;
endinterface
module top ();
  bbb i ();
  aaa p ();
endmodule
