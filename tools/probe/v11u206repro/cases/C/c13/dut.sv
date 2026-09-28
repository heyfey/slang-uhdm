// § unitClassTdEndAtInitIfcPrg206
virtual class obj; endclass
class cfg#(type T=int, type T2=int);
endclass
typedef cfg#(obj, string) m_misc;
interface ifc ();
  m_misc a = new;
endinterface
program prg (ifc i);
  initial begin
    m_misc x = new;
  end
endprogram
module top ();
  ifc i ();
  prg p (i);
endmodule
