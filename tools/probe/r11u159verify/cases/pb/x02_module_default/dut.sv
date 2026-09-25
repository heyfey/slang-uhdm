// § crossPkgFoldTsNameOnChain152
package pk;
  parameter int unsigned N = 2;
  parameter int unsigned MSB = 2;
  parameter logic [MSB:0] R[N] = '{3'h1, 3'h6};
endpackage
module child #(parameter logic [2:0] D = pk::R[0])(output logic [2:0] o);
  assign o = D;
endmodule
module top(output logic [2:0] o);
  child u(.o(o));
endmodule
