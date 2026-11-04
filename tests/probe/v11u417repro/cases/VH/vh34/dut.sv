// § hierSelParenBoundPretty417
class C;
  logic [63:0] d;
endclass
module top (input logic [3:0] i, output logic [3:0] o);
  C obj;
  always_comb o = obj.d[(i*4)+:4];
endmodule
