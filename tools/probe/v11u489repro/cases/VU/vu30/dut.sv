// § untypedDepUnboundedValue489
module m #(parameter A = 4'd2) (output logic [7:0] o);
localparam B = A + 4'd1; assign o = B;
endmodule
module top; logic [7:0] o;
m #(.A(4'd15)) u(o);
endmodule
