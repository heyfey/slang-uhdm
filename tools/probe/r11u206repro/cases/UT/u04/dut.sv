// § unitClassTdEndAtInitIfcPrg206
virtual class obj; endclass
class cfg#(type T=int, type T2=int);
endclass
typedef cfg#(obj, string) m_misc;
interface zzz ();
  m_misc a =
     new;
endinterface
module aaa ();
  m_misc b = new;
  zzz i ();
endmodule
