// § tfBodyTypedefIsItem304
package p;
  function automatic int f(int a);
    typedef int n_t;
    typedef n_t m_t;
    m_t x;
    x = a;
    return x;
  endfunction
endpackage
module top; endmodule
