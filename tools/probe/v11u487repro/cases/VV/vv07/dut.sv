// § caFoldValueFollowsPa487
class K; localparam int w = 3; endclass
module m #(parameter A = 4) (output logic [7:0] o); localparam B = A + 1; assign o = B; endmodule
module top; logic [7:0] o; m #(.A(K::w)) u(o); endmodule
