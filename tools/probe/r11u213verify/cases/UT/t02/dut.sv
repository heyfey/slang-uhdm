// § unitClassTdEndAtInitIfcPrg206 (kinds in alphabetical order: ifc mod prg)
virtual class obj; endclass
class cfg#(type T=int, type T2=int);
endclass
typedef cfg#(obj, string) m_misc;
program zz2 ();
  m_misc p = new
     ;
endprogram
module mm2 ();
  m_misc b =
         new;
  aa2 i ();
  zz2 q ();
endmodule
interface aa2 ();
  m_misc a = new;
endinterface
