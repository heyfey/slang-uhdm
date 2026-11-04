// § unitClassTdEndAtInit202
virtual class obj; endclass
class cfg#(type T=int, type T2=int);
endclass
typedef cfg#(obj, string) m_misc;
module top ();
  m_misc a = new;
endmodule
module mid ();
  m_misc b = new;
endmodule
