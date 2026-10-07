// § genLoopDirectBoundPaCopy280
// an interface body with the bound in a for-generate, and a module beside it
interface ifc (input logic [31:0] sig);
  localparam logic [3:0] R4 = {2{2'b01}};
  logic [1:0] o [2];
  for (genvar i = 0; i < 2; i++) begin : g
    assign o[i] = sig[R4 +: 2];
  end
endinterface
module top (input logic [31:0] sig); ifc u (.sig(sig)); endmodule
