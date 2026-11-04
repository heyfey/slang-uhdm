// § unitClassTdEndAtInit202 § unitClassTdSpecAtName202
virtual class obj;
endclass
class cfg#(type T=int, type T2=int);
endclass
typedef cfg#(obj, string) m_misc;
module zz ();
  m_misc a = new;
endmodule
module mm ();
  m_misc b = new();
  m_misc c;
endmodule
module aa ();
  m_misc d = new;
  zz z();
  mm m();
endmodule
