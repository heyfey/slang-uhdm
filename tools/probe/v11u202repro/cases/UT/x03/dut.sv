// § unitClassTdEndAtInit202
virtual class obj; endclass
class cfg#(type T=int, type T2=int);
endclass
typedef cfg#(obj, string) m_misc;
module top ();
  if (1) begin : g
    m_misc a = new;
  end
  m_misc b;
endmodule
