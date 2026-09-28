// § unitClassTdEndAtInitIfcPrg206 (kinds in alphabetical order: prg mod ifc)
virtual class obj; endclass
class cfg#(type T=int, type T2=int);
endclass
typedef cfg#(obj, string) m_misc;
program aa4 ();
  m_misc p = new
     ;
endprogram
module mm4 ();
  m_misc b =
         new;
  zz4 i ();
  aa4 q ();
endmodule
interface zz4 ();
  m_misc a = new;
endinterface
