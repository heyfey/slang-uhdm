// G2: two instances of the concatenation-initialized parameter's module.
module sub(output int o);
  parameter int A3[0:2] = {1, 2, 3};
  assign o = A3[0];
endmodule
module top(output int o, output int p);
  sub u(.o(o));
  sub v(.o(p));
endmodule
