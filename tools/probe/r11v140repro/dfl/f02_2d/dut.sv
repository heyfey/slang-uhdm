// § defaultFillOneConstant140
module sub #(parameter int A[2][2] = '{default: 0}) (output int o);
  assign o = A[0][1];
endmodule
module top(output int o); sub u(.o(o)); endmodule
