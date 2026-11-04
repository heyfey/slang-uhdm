// § tfBodyTypedefForcesBegin304
package p;
  function automatic int f(int a);
    typedef int n_t;
    if (a) return 1; else return 0;
  endfunction
endpackage
module top; endmodule
