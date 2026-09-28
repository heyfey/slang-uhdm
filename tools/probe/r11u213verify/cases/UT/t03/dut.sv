// § unitClassTdEndAtInitIfcPrg206 (kinds in alphabetical order: prg ifc mod)
virtual class obj; endclass
class cfg#(type T=int, type T2=int);
endclass
typedef cfg#(obj, string) m_misc;
program aa3 ();
  m_misc p = new
     ;
endprogram
module zz3 ();
  m_misc b =
         new;
  mm3 i ();
  aa3 q ();
endmodule
interface mm3 ();
  m_misc a = new;
endinterface
