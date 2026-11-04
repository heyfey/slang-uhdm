// § untypedDepUnboundedValue489
module top(output logic [7:0] o); module n #(parameter A = 4'd15) (output logic [7:0] q); localparam B = A + 4'd1; assign q = B; endmodule n u(o); endmodule
