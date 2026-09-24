// § defaultFillOneConstant140
package pk;
  parameter int A[3] = '{default: 5};
endpackage
module top(output int o);
  import pk::*;
  assign o = A[1];
endmodule
