// § unitClassTdEndAtInitIfcPrg206 (kinds in alphabetical order: mod ifc prg)
virtual class obj; endclass
class cfg#(type T=int, type T2=int);
endclass
typedef cfg#(obj, string) m_misc;
program zz5 ();
  m_misc p = new
     ;
endprogram
module aa5 ();
  m_misc b =
         new;
  mm5 i ();
  zz5 q ();
endmodule
interface mm5 ();
  m_misc a = new;
endinterface
