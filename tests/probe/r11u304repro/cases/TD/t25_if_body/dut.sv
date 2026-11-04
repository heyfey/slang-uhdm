// § tfBodyTypedefForcesBegin304
package p;
  int q;
  function automatic int g(int a);
    typedef bit [2:0] s_t;
    if (a > 1) return a; else return 0;
  endfunction
endpackage
module top; endmodule
