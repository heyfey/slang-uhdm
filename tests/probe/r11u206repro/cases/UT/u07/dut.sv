// § unitClassTdEndAtInitIfcPrg206
virtual class obj; endclass
class cfg#(type T=int, type T2=int);
endclass
typedef cfg#(obj, string) m_misc;
program bbb ();
  m_misc a = new;
endprogram
program aaa ();
  m_misc a =
     new;
endprogram
module top ();
  bbb p ();
  aaa q ();
endmodule
