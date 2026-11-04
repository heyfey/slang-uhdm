// § nestedRepPatCount64_405
module top(output int o);
  int a [2][2][2] = '{2{'{2{'{2{8}}}}}};
  assign o = a[1][1][0];
endmodule
