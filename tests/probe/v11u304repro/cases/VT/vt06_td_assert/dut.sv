// § tfBodyTypedefForcesBegin304
package p;
  function automatic void f(int a);
    typedef int n_t;
    assert (a > 0);
  endfunction
endpackage
module top; endmodule
