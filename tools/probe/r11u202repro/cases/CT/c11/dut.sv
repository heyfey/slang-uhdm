// § unitClassTdSpecAtName202
class cfg#(type T=int, type T2=int);
endclass
module top ();
  typedef cfg#(int, string) m_misc;
  m_misc misc1;
endmodule
