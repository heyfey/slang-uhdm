// § modArrConcatInitElemSize430
module top(input logic [1:0] s, output logic [3:0] o);
  logic [3:0] lut [0:3] = {4'd0, 4'd1, 4'd3, 4'd7};
  always_comb o = lut[s];
endmodule
