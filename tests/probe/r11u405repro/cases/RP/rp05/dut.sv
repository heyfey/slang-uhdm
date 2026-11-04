// § nestedRepPatCount64_405
module top();
  int a, b;
  int v [1:0][1:0];
  initial v = '{2{'{a, b}}};
endmodule
