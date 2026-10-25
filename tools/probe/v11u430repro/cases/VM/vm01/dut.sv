// § modArrConcatInitElemSize430
module top(input logic [1:0] a, output logic [7:0] o);
  logic [7:0] mem [0:3] = {8'd1, 8'd2, 8'd3, 8'd4};
  assign o = mem[a];
endmodule
