// § tfBodyTypedefIsItem304
package p;
  function automatic int g(int a);
    int b;
    typedef bit [2:0] s_t;
    s_t v;
    v = a[2:0];
    return v + b;
  endfunction
endpackage
module top; endmodule
