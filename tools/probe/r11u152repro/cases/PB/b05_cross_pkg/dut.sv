// § crossPkgFoldTsNameOnChain152
package pb;
  parameter int unsigned MSB = 5;
endpackage
package pk;
  parameter int unsigned N = 2;
  parameter logic [pb::MSB:0] Rst[N] = '{6'h0, 6'h1};
endpackage
module top(output logic [5:0] o);
  assign o = 6'd0;
endmodule
