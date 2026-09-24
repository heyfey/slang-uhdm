// § defaultFillOneConstant140
module sub #(parameter int A[2] = '{default: 3}) (output int o);
  assign o = A[0];
endmodule
module top(output int o);
  sub u(.o(o));
endmodule
