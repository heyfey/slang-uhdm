// § crossPkgFoldTsNameOnChain152
package pk;
  parameter int unsigned N = 3;
  parameter int unsigned MSB = 3;
  parameter int unsigned LSB = 1;
  parameter logic [MSB:LSB] A[N] = '{3'h0, 3'h1, 3'h2};
  parameter bit [MSB:0] B[2] = '{4'h0, 4'h1};
endpackage
module top(output logic [5:0] o);
  assign o = 6'd0;
endmodule
