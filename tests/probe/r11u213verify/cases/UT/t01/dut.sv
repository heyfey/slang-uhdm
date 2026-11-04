// § unitClassTdEndAtInitIfcPrg206 (kinds in alphabetical order: ifc prg mod)
virtual class obj; endclass
class cfg#(type T=int, type T2=int);
endclass
typedef cfg#(obj, string) m_misc;
program mm1 ();
  m_misc p = new
     ;
endprogram
module zz1 ();
  m_misc b =
         new;
  aa1 i ();
  mm1 q ();
endmodule
interface aa1 ();
  m_misc a = new;
endinterface
