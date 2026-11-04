// § unitClassTdSpecAtName202
package p;
class cfg#(type T=int, type T2=int);
endclass
class obj; endclass
class user;
  typedef cfg#(int, string) m_misc;
  typedef cfg#(obj, string) m_obj;
  m_obj h = new;
endclass
endpackage
module top ();
endmodule
