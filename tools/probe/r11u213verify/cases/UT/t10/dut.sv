// § unitClassTdEndAtInitIfcPrg206 (a checker beside an interface and a program)
virtual class obj; endclass
class cfg#(type T=int, type T2=int);
endclass
typedef cfg#(obj, string) m_misc;
interface ifc ();
  m_misc a = new;
endinterface
program prg ();
  m_misc c =
     new;
endprogram
checker chk (logic clk);
  logic seen = 1'b0;
endchecker
module top ();
  logic clk;
  ifc i ();
  prg p ();
  chk k (clk);
endmodule
