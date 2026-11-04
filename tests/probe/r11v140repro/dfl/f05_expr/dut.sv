// § defaultFillOneConstant140
module sub #(parameter int W = 2, parameter int A[3] = '{default: W + 1}) (output int o);
  assign o = A[2];
endmodule
module top(output int o); sub u(.o(o)); endmodule
