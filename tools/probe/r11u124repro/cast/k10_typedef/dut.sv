// § castTsFile124
typedef logic [3:0] n_t; module top(output n_t o); logic [7:0] a = 8'hAB; assign o = n_t'(a); endmodule
