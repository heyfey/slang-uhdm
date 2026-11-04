// § tfBodyTypedefIsItem304
package p;
  function automatic int f(int a);
    typedef logic [3:0] n_t;
    n_t b;
    b = a;
    return b;
  endfunction
endpackage
package q;
  import p::*;
endpackage
module top; endmodule
