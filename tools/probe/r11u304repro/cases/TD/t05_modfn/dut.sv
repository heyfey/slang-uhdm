// § tfBodyTypedefIsItem304
module top(input int a, output int o);
  function automatic int g(int x);
    typedef bit [2:0] s_t;
    s_t v;
    v = x[2:0];
    return v;
  endfunction
  assign o = g(a);
endmodule
