// § genLoopDirectBoundPaCopy280
// a select left side
module top (input logic [31:0] sig, output logic [3:0] o);
  localparam logic [3:0] R4 = {2{2'b01}};
  for (genvar i = 0; i < 2; i++) begin : g
    assign o[2*i +: 2] = sig[R4 +: 2];
  end
endmodule
