// § unboundedAddSize489
module m #(parameter A = 4'd0) (output logic [7:0] o);
localparam B = A - 4'd1; assign o = B;
endmodule
module top; logic [7:0] o;
m u(o);
endmodule
