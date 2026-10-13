// § tfBodyTypedefIsItem304
package p;
  function automatic int g(int a);
    typedef bit [2:0] s_t;
    typedef bit [3:0] u_t;
    s_t v;
    v = a[2:0];
    return v;
  endfunction
endpackage
module top; endmodule
