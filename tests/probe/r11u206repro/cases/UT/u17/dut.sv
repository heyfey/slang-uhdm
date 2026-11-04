// § unitClassTdEndAtInitIfcPrg206
virtual class obj; endclass
class cfg#(type T=int, type T2=int);
endclass
typedef cfg#(obj, string) m_misc;
interface ifc ();
  m_misc a;
  initial begin
    m_misc z = new;
  end
endinterface
module top ();
  ifc i ();
endmodule
