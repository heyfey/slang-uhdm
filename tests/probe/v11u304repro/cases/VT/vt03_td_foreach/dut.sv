// § tfBodyTypedefForcesBegin304
package p;
  function automatic void f(ref int q[$]);
    typedef int n_t;
    foreach (q[i]) q[i] = 0;
  endfunction
endpackage
module top; endmodule
