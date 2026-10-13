// § tfBodyTypedefIsItem304
package p;
  function automatic int g(int a);
    localparam int K = 2;
    typedef bit [2:0] s_t;
    s_t v;
    v = a[2:0] + K;
    return v;
  endfunction
endpackage
module top; endmodule
