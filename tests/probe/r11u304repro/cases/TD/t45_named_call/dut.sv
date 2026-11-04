// § tfBodyTypedefForcesBegin304
package p;
  int q;
  function automatic int g(int a, int b);
    typedef bit [2:0] s_t;
    return a + b;
  endfunction
  function automatic void h();
    q = g(.b(1), .a(2));
  endfunction
endpackage
module top; endmodule
