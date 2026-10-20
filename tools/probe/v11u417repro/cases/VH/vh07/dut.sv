// § hierSelParenBoundPretty417
interface ifc;
  logic [63:0] d;
endinterface
module top (input logic [3:0] i, output logic [3:0] o);
  ifc u();
  assign o = u.d[(i)+:4];
endmodule
