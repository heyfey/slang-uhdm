// § paramValueIsDefRhs124
module top(output int o); parameter int N = -5; parameter int M = 2 - 7; parameter logic [7:0] K = -1; assign o = N + M + K; endmodule
