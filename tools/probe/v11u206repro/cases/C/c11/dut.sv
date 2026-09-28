// § unitClassTdEndAtInitIfcPrg206
virtual class obj; endclass
class cfg#(type T=int, type T2=int);
endclass
typedef cfg#(obj, string) m_misc;
module top ();
  interface inner ();
    m_misc a = new;
  endinterface
  inner i ();
endmodule
program prg ();
  m_misc c = new;
endprogram
