// § crossPkgFoldTsNameOnChain152
package pk;
  parameter int unsigned MSB = 5;
endpackage
module top(output logic [5:0] o);
  parameter logic [pk::MSB:0] Rst[2] = '{6'h0, 6'h1};
  assign o = Rst[0];
endmodule
