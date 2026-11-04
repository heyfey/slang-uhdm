// § bareOvRefUint64_487
module m #(parameter A = 4) (output logic [7:0] o); localparam B = A; assign o = B; endmodule
module top #(parameter P = 3) (output logic [7:0] o); m #(.A(P)) u(o); endmodule
