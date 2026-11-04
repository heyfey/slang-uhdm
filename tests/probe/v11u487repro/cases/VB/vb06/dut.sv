// § bareOvRefUint64_487
module m #(parameter A = 4) (output logic [7:0] o); localparam B = A; wire [B-1:0] w; assign o = $bits(w); endmodule
module top; logic [7:0] o; m #(.A(5)) u(o); endmodule
