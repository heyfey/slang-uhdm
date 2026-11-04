// § tfBodyTypedefIsItem304
package p;
  function automatic int f(int a);
    typedef logic [3:0] n_t;
    n_t b, c;
    b = a;
    c = b;
    return c;
  endfunction
endpackage
module top; endmodule
