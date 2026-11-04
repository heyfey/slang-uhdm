// § modArrConcatInitElemSize430
module top(input logic s, output logic [7:0] o); logic [7:0] mem [2] = {8'hFF, 0}; assign o = mem[s]; endmodule
