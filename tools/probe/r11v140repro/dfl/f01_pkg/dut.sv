// § defaultFillOneConstant140
package pk;
  parameter int A[3] = '{default: 7};
endpackage
module top(output int o); assign o = pk::A[1]; endmodule
