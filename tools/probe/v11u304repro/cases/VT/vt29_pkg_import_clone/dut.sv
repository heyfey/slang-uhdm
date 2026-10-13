// § tfBodyTypedefForcesBegin304
package p;
  function automatic int f(int a);
    typedef logic [3:0] n_t;
    return n_t'(a) + 1;
  endfunction
endpackage
package q;
  import p::*;
  function automatic int g(int a); return f(a); endfunction
endpackage
module top; endmodule
