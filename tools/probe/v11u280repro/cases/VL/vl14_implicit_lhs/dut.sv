// § genLoopDirectBoundPaCopy280
// an implicit net left side and a generate-local net left side with the bound
module top (input logic [31:0] sig);
  localparam logic [3:0] R4 = {2{2'b01}};
  for (genvar i = 0; i < 2; i++) begin : g
    wire [1:0] w;
    assign w = sig[R4 +: 2];
    assign imp = sig[R4];
  end
endmodule
