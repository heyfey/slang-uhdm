// § unboundedAddSize489
module m #(parameter A = 4'd2) (output logic [7:0] o);
localparam B = A + 4'd1; localparam C = B + 4'd1; assign o = C;
endmodule
module top; logic [7:0] o;
m u(o);
endmodule
