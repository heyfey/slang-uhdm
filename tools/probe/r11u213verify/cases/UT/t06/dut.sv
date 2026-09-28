// § unitClassTdEndAtInitIfcPrg206 (kinds in alphabetical order: mod prg ifc)
virtual class obj; endclass
class cfg#(type T=int, type T2=int);
endclass
typedef cfg#(obj, string) m_misc;
program mm6 ();
  m_misc p = new
     ;
endprogram
module aa6 ();
  m_misc b =
         new;
  zz6 i ();
  mm6 q ();
endmodule
interface zz6 ();
  m_misc a = new;
endinterface
