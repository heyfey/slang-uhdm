// § unitClassTdEndAtInitIfcPrg206
virtual class obj; endclass
class cfg#(type T=int, type T2=int);
endclass
package pk;
  typedef cfg#(obj, string) m_misc;
endpackage
interface ifc ();
  pk::m_misc a = new;
endinterface
module top ();
  ifc i ();
endmodule
