// § newArrayPartSelStripped227
module top(output int o);
  logic [7:0] v;
  int k;
  function automatic int f();
    int la[];
    la = new[v[1:0]];
    return la.size();
  endfunction
  initial o = f();
endmodule
