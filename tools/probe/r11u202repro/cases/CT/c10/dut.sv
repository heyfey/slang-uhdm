// § unitClassTdSpecAtName202
package p;
class cfg#(type T=int, type T2=int);
endclass
typedef cfg#(int, string) m_misc;
endpackage
module top ();
  p::m_misc misc1;
endmodule
