// § tfBodyTypedefIsItem304
package p;
  function automatic int f(int a);
    int b;
    int c;
    typedef logic [3:0] n_t;
    b = a;
    c = b;
    return c;
  endfunction
endpackage
module top; endmodule
