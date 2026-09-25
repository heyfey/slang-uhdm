// § crossPkgFoldTsNameOnChain152
package wk;
  parameter int unsigned MSB = 3;
endpackage
package pk;
  import wk::*;
  parameter int unsigned N = 2;
  parameter logic [MSB:0] R[N] = '{4'h1, 4'h2};
endpackage
module top(output logic [3:0] o);
  assign o = pk::R[1];
endmodule
