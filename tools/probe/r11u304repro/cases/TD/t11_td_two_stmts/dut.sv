// § tfBodyTypedefIsItem304
package p;
  int q;
  function automatic int g(int a);
    typedef bit [2:0] s_t;
    q = a;
    return a + 1;
  endfunction
endpackage
module top; endmodule
