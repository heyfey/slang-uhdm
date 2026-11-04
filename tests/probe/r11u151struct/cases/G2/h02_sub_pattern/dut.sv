// G2: a control: the same parameter initialized by an assignment pattern.
module sub(output int o);
  parameter int A3[0:2] = '{1, 2, 3};
  assign o = A3[2];
endmodule
module top(output int o);
  sub u(.o(o));
endmodule
