// § untypedDepUnboundedValue489
module m #(parameter A = 4'd15) (output logic [7:0] o);
localparam B = 8'd200 + 8'd100; logic [B-1:0] x; assign o = x[7:0];
endmodule
module top; logic [7:0] o;
m u(o);
endmodule
