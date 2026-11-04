// § tfBodyTypedefIsItem304
package q; int z; endpackage
package p;
  function automatic int f(int a);
    typedef int n_t;
    import q::*;
    n_t b;
    b = a + z;
    return b;
  endfunction
endpackage
module top; endmodule
