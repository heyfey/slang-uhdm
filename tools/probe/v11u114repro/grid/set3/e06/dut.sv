// transitive: pk2 imports and exports P
package pk; parameter logic [7:0] P = {4'h7, 4'h3}; endpackage
package pk2; import pk::P; export pk::P; parameter logic [7:0] Q = 8'h1; endpackage
module top import pk2::*; (input logic [7:0] x, output logic [3:0] y);
  always_comb case (x) P: y = 4'd1; Q: y = 4'd2; default: y = 4'd0; endcase
endmodule
