// § nestedRepPatCount64_405
module top(output int o);
  localparam int a [2][2] = '{'{2{1}}, '{2{3}}};
  assign o = a[1][0];
endmodule
