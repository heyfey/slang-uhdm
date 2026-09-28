// § unitClassTdEndAtInitIfcPrg206
virtual class obj; endclass
class cfg#(type T=int, type T2=int);
endclass
typedef cfg#(obj, string) m_misc;
module outer ();
  m_misc b = new;
  inner u ();
endmodule
interface inner ();
  m_misc a = new;
endinterface
program p1 (); m_misc x = new; endprogram
program p2 (); m_misc y = new; endprogram
