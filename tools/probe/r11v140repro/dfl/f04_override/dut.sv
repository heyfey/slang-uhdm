// § defaultFillOneConstant140
module sub #(parameter int A[2] = '{default: 3}) (output int o);
  assign o = A[1];
endmodule
module top(output int o, output int o2); sub #(.A('{default: 5})) u(.o(o)); sub u2(.o(o2)); endmodule
