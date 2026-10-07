// § genLoopDirectBoundPaCopy280
// a generate-local localparam shadowing a module localparam of the same name as the bound
module top (input logic [31:0] sig, output logic [1:0] o [2]);
  localparam logic [3:0] R4 = {2{2'b01}};
  for (genvar i = 0; i < 2; i++) begin : g
    localparam logic [3:0] R4 = {2{2'b10}};
    assign o[i] = sig[R4 +: 2];
  end
endmodule
