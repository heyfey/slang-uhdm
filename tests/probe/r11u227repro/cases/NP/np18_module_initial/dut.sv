// § newArrayPartSelStripped227
module top(output int o);
  logic [7:0] v;
  int k;
  int la[];
  initial begin
    la = new[v[k+:2]];
    o = la.size();
  end
endmodule
