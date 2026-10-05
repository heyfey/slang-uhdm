// § impArrParamTsOwnRanges242
// An importer WITH a parameter port list (the topView flip does not reach unpacked arrays)
// and an interface importer.
package hp;
  typedef logic [7:0] b_t;
  parameter b_t K [4] = '{8'h1, 8'h2, 8'h3, 8'h4};
endpackage
interface ifc import hp::*; (input logic [1:0] j);
  logic [7:0] v;
  assign v = K[j];
endinterface
module top import hp::*; #(parameter int P = 1) (input logic [1:0] j, output logic [7:0] o);
  ifc i0 (.j(j));
  assign o = K[j] ^ i0.v;
endmodule
