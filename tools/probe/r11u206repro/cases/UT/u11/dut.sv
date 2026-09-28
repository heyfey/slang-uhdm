// § unitClassTdEndAtInitIfcPrg206
virtual class obj; endclass
class cfg#(type T=int, type T2=int);
endclass
typedef cfg#(obj, string) m_misc;
interface bbb ();
  m_misc a = new;
endinterface
program aaa ();
  m_misc c =
     new;
endprogram
module top ();
  bbb i ();
  aaa p ();
endmodule
