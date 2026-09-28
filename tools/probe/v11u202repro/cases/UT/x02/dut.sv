// § unitClassTdEndAtInit202
virtual class obj; endclass
class cfg#(type T=int, type T2=int);
endclass
typedef cfg#(obj, string) m_misc;
program prg ();
  m_misc a = new;
endprogram
module top ();
  prg p ();
endmodule
