// § newArrayPartSelStripped227
module top(output int o);
  logic [7:0] v;
  int k;
  for (genvar g = 0; g < 2; g++) begin : gb
    int la[];
    initial la = new[v[g*2 +: 2]];
  end
  assign o = 0;
endmodule
