// § crossPkgFoldTsNameOnChain152
package pk;
  parameter int unsigned MSB = 3;
  parameter logic [1:0][MSB:0] R = '{4'h1, 4'h2};
  parameter logic [MSB:0] U = 4'h3;
endpackage
module top(output logic [3:0] o);
  assign o = pk::U;
endmodule
