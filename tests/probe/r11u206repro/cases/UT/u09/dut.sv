// § unitClassTdEndAtInitIfcPrg206
virtual class obj; endclass
class cfg#(type T=int, type T2=int);
endclass
typedef cfg#(obj, string) m_misc;
module aaa ();
  m_misc b = new;
  zzz p ();
endmodule
program zzz ();
  m_misc a =
     new;
endprogram
