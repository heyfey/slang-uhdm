// § genLoopDirectBoundPaCopy280
// the replication localparam as a replication count, a dimension bound, a localparam default and a select bound together
module top (input logic [31:0] sig, output logic [7:0] o [2], output logic [1:0] p [2]);
  localparam logic [3:0] R4 = {2{2'b01}};
  for (genvar i = 0; i < 2; i++) begin : g
    localparam int LW = R4;
    logic [R4:0] d;
    assign d = '0;
    assign o[i] = {R4{1'b1}} | 8'(LW);
    assign p[i] = sig[R4 +: 2];
  end
endmodule
