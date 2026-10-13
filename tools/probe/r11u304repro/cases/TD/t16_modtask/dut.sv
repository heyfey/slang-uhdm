// § tfBodyTypedefIsItem304
module top(input int a, output int o);
  task automatic t(int x);
    typedef bit [2:0] s_t;
    s_t v;
    v = x[2:0];
    o = v;
  endtask
  initial t(a);
endmodule
