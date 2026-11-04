// § tfBodyTypedefForcesBegin304
package q; int z; endpackage
package p;
  function automatic int f(int a);
    typedef int n_t;
    import q::*;
    return a + z;
  endfunction
endpackage
module top; endmodule
