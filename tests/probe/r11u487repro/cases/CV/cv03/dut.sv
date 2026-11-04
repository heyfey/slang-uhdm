// § caFoldValueFollowsPa487
class K; parameter w = 3; endclass
module m #(parameter A = 4, localparam B = A) (output logic [7:0] o); localparam C = 9; assign o = B; endmodule
module top; logic [7:0] o1, o2; m #(.A(K::w)) u1(o1); m u2(o2); endmodule
