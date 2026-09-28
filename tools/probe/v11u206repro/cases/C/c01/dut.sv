// § unitClassTdEndAtInitIfcPrg206
virtual class obj; endclass
class cfg#(type T=int, type T2=int);
endclass
typedef cfg#(obj, string) m_misc;
program zzz ();
  m_misc p = new;
endprogram
interface mmm ();
  m_misc a = new;
endinterface
module aaa ();
  m_misc b;
  mmm i ();
  zzz q ();
endmodule
