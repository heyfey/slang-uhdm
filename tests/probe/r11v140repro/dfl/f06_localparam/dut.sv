// § defaultFillOneConstant140
module top(output int o);
  localparam int A[4] = '{default: 9};
  assign o = A[3];
endmodule
