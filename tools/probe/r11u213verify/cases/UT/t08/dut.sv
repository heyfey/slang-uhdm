// § unitClassTdEndAtInitIfcPrg206 (control: a PACKAGE class typedef (a package cannot reference a $unit item) with a package variable, an interface variable and a program variable of it)
package pk;
  virtual class obj; endclass
  class cfg#(type T=int, type T2=int);
  endclass
  typedef cfg#(obj, string) m_misc;
  m_misc pv = new
     ;
endpackage
interface ifc ();
  pk::m_misc a = new;
endinterface
program prg ();
  pk::m_misc c =
     new;
endprogram
module top ();
  ifc i ();
  prg p ();
endmodule
