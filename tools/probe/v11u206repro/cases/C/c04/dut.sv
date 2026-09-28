// § unitClassTdEndAtInitIfcPrg206
virtual class obj; endclass
class cfg#(type T=int, type T2=int);
endclass
typedef cfg#(obj, string) m_misc;
package pk;
  int z;
endpackage
interface ifc ();
  if (1) begin : g
    m_misc a = new;
  end
endinterface
program prg ();
  m_misc c = new;
endprogram
module top ();
  ifc i ();
  prg q ();
endmodule
