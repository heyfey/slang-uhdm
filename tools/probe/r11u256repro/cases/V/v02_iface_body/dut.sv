// § genIpsBoundOwner256 (an interface body for-generate)
package fp;
  parameter int FW = 2;
  parameter int PW = 3;
endpackage
interface ifc import fp::*; (input logic [7:0] a);
  logic [2:0] t [2];
  for (genvar i = 0; i < 2; i++) begin : gb
    assign t[i] = a[FW +: PW] ^ a[0 +: PW];
  end
endinterface
module top(input logic [7:0] a, output logic [2:0] o);
  ifc i (.a(a));
  assign o = i.t[0];
endmodule
