// § genIpsBoundOwner256 (an interface with a for-generate body, instantiated inside an if-generate at depth 2)
package fp;
  parameter int FW = 2;
  parameter int PW = 3;
endpackage
interface ifc import fp::*; (input logic [7:0] a);
  logic [2:0] t [2];
  for (genvar i = 0; i < 2; i++) begin : gb
    assign t[i] = a[FW +: PW] | a[i +: PW];
  end
endinterface
module mid(input logic [7:0] a, output logic [2:0] o);
  if (1) begin : gi
    ifc i (.a(a));
    assign o = i.t[1];
  end
endmodule
module top(input logic [7:0] a, output logic [2:0] o);
  mid u (.a(a), .o(o));
endmodule
