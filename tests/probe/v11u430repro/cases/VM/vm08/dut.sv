// § modArrConcatInitElemSize430
module top(output logic [3:0] o); logic [3:0] a [2] = {4'h1, 'h2}; assign o = a[1]; endmodule
