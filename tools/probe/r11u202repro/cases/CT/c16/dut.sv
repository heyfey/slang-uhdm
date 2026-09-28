// § unitClassTdSpecAtName202
class obj; endclass
class cfg#(type T=int, type T2=int);
endclass
typedef cfg#(obj, string) m_obj;
typedef cfg#(obj) m_obj1;
module top ();
  m_obj a = new;
  m_obj b;
  initial b = new;
endmodule
