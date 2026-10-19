// § nestedRepPatCount64_405
module top(output int o[1:2][1:2]);
  assign o = '{2{'{2{7}}}};
endmodule
