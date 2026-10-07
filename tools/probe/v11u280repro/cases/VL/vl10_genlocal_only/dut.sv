// § genLoopDirectBoundPaCopy280
// a generate-local replication localparam with no module namesake, and a module namesake of another name
module top (input logic [31:0] sig, output logic [1:0] o [2], output logic [1:0] p [2]);
  localparam logic [3:0] R5 = {2{2'b10}};
  for (genvar i = 0; i < 2; i++) begin : g
    localparam logic [3:0] R4 = {2{2'b01}};
    assign o[i] = sig[R4 +: 2];
    assign p[i] = sig[R5 +: 2];
  end
endmodule
