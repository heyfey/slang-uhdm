// § crossPkgFoldTsNameOnChain152
package pk;
  parameter int unsigned N = 2;
  parameter int unsigned MSB = 5;
  parameter logic [MSB:0] Rst[N] = '{6'h0, 6'h1};
endpackage
module top(output logic [5:0] o);
  assign o = pk::Rst[1];
endmodule
