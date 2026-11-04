// § nestedRepPatCount64_405
module top(output int o);
  int a [3][2];
  initial begin
    a = '{'{1, 2}, '{2{4}}, '{2{6}}};
    o = a[2][1];
  end
endmodule
