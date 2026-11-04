// § unboundedDepBesideDefparam491
module m #(parameter A = 8'd200, parameter X = 1) (output logic [7:0] o);
localparam B = A + 8'd100; localparam C = B + X; assign o = C;
endmodule
module top; logic [7:0] o;
m u(o); defparam u.X = 2;
endmodule
