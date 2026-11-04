// § bareOvRefUint64_487
module m #(parameter logic [7:0] A = 4) (output logic [7:0] o); localparam B = A; assign o = B; endmodule
module top; logic [7:0] o; m #(.A(5)) u(o); endmodule
