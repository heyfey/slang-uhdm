// § genLoopDirectBoundPaCopy280
// a bit-select index and a plain operand (other windows: control)
module top (input logic [31:0] sig, output logic [63:0] z);
  localparam logic [3:0] R4 = {2{2'b01}};
  for (genvar i = 0; i < 2; i++) begin : g
    logic y0;
    logic [3:0] y1;
    assign y0 = sig[R4];
    assign y1 = R4 ^ sig[3:0];
  end
  assign z = 64'b0;
endmodule
