// § newArrayPartSelStripped227
module top(output int o);
  logic [7:0] v;
  int k;
  int la[];
  task automatic t();
    la = new[v[k+:3]];
  endtask
  initial begin t(); o = la.size(); end
endmodule
