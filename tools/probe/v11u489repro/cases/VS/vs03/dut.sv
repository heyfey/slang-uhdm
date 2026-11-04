// § unboundedAddSize489
module m #(parameter A = 4'd15) (output logic [7:0] o);
localparam B = 4'd3 + 4'd2; logic [B:0] x; assign o = x;
endmodule
module top; logic [7:0] o;
m u(o);
endmodule
