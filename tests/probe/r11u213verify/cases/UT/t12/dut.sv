// § unitClassTdEndAtInitIfcPrg206 (two declarators in one program, a later interface parameterized and instantiated twice)
virtual class obj; endclass
class cfg#(type T=int, type T2=int);
endclass
typedef cfg#(obj, string) m_misc;
program prg ();
  m_misc c = new, d = new
    ;
endprogram
interface ifc #(parameter int N = 1) ();
  m_misc a = new;
  m_misc e;
endinterface
module top ();
  ifc #(2) i ();
  ifc #(3) j ();
  prg p ();
endmodule
