// § tfBodyTypedefForcesBegin304
package p;
  function automatic int f(int a);
    typedef int n_t;
    for (int i = 0; i < 2; i++) a = a + i;
  endfunction
endpackage
module top; endmodule
