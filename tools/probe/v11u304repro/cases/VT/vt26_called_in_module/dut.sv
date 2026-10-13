// § tfBodyTypedefForcesBegin304
package p;
  function automatic int f(int a);
    typedef logic [3:0] n_t;
    return n_t'(a);
  endfunction
endpackage
module top (input int a, output int y);
  assign y = p::f(a);
endmodule
