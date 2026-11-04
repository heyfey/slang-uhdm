// § untypedDepUnboundedValue489
module m #(parameter A = 8'd200) (output logic [15:0] o); localparam B = A + 8'd100; localparam C = B + 1; assign o = C; endmodule
module top; logic [15:0] o; m u(o); endmodule
