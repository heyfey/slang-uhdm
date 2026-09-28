// § unitClassTdEndAtInit202
class cfg#(type T=int, type T2=int);
endclass
typedef cfg#(int, string) m_misc;
module top ();
  function automatic void f();
    m_misc a = new;
  endfunction
  m_misc b = new,
         c = new;
endmodule
