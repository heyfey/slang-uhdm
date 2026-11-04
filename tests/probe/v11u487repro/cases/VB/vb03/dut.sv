// § bareOvRefUint64_487
module m #(parameter A = 4) (output logic [7:0] o); localparam B = A; assign o = B; endmodule
module top; logic [7:0] o1, o2; m #(.A(5)) u1(o1); m u2(o2); endmodule
