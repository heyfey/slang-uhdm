// § unitClassTdEndAtInitIfcPrg206 (two interfaces and a program, no module writer, the alphabetically last interface declared first)
virtual class obj; endclass
class cfg#(type T=int, type T2=int);
endclass
typedef cfg#(obj, string) m_misc;
interface zi ();
  m_misc a = new;
endinterface
program zp ();
  m_misc c =
   new;
endprogram
interface ai ();
  m_misc b = new
  ;
endinterface
module top ();
  logic x;
  ai u ();
  zi v ();
  zp w ();
endmodule
