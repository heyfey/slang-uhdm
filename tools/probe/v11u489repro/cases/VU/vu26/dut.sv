// § untypedDepUnboundedValue489
module m #(parameter A = 4'd15) (output logic [7:0] o);
localparam B = 1 << 31; logic [31:0] w; assign w = B; assign o = w[7:0];
endmodule
module top; logic [7:0] o;
m u(o);
endmodule
