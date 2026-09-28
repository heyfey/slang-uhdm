// § unitClassTdEndAtInitIfcPrg206
virtual class obj; endclass
class cfg#(type T=int, type T2=int);
endclass
typedef cfg#(obj, string) m_misc;
interface ifc #(parameter int W = 2) ();
  logic [W-1:0] x;
  m_misc a = new;
endinterface
module top ();
  ifc #(.W(3)) i ();
  ifc j ();
endmodule
