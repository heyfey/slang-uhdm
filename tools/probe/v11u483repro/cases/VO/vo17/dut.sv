// § clsScopedOvRhsRefObj483
class K; parameter w = 3; endclass
module m (o); output logic [7:0] o; parameter A = 4; assign o = A; endmodule
module top; logic [7:0] o; m #(.A(K::w)) u(o); endmodule
