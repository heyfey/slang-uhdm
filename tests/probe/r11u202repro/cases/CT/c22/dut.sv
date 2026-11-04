// § unitClassTdEndAtInit202
virtual class obj;
endclass
class cfg#(type T=int, type T2=int);
endclass
typedef cfg#(obj, string) m_misc;
module top ();
  initial begin
    m_misc a = new;
  end
endmodule
