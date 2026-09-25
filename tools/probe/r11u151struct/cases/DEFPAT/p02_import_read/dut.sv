// DEFPAT: the imported default-fill array read by a continuous assignment.
package pk;
  parameter int A[2] = '{default: 5};
endpackage
module top(output int o);
  import pk::*;
  assign o = A[1];
endmodule
