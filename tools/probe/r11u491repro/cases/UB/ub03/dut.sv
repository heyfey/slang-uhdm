// § unboundedDepBesideDefparam491
module m #(parameter A = 4'd0, parameter X = 1) (output logic [7:0] o);
localparam B = A - 4'd1; localparam C = X; assign o = B + C;
endmodule
module top; logic [7:0] o;
m u(o); defparam u.X = 2;
endmodule
