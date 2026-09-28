// § unitClassTdEndAtInitIfcPrg206 (a module whose only variable sits in a generate block, an interface variable)
virtual class obj; endclass
class cfg#(type T=int, type T2=int);
endclass
typedef cfg#(obj, string) m_misc;
interface ifc ();
  m_misc a =
       new;
endinterface
module top ();
  if (1) begin : g
    m_misc b = new;
  end
  ifc i ();
endmodule
