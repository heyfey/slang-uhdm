// § unitClassTdEndAtInitIfcPrg206
virtual class obj; endclass
class cfg#(type T=int, type T2=int);
endclass
typedef cfg#(obj, string) m_misc;
program aaa ();
  m_misc a =
     new;
endprogram
module zzz ();
  m_misc b = new;
  aaa p ();
endmodule
