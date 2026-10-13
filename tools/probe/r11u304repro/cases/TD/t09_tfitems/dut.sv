// § tfBodyTypedefIsItem304
package p;
  function automatic int g;
    input int a;
    typedef bit [2:0] s_t;
    s_t v;
    v = a[2:0];
    return v;
  endfunction
endpackage
module top; endmodule
