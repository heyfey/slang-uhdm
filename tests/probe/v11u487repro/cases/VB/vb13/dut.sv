// § bareOvRefUint64_487
module m #(parameter type T = int, parameter A = 4) (output logic [7:0] o); localparam B = A; assign o = B; endmodule
module top; logic [7:0] o; m #(logic, 6) u(o); endmodule
