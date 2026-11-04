// § unboundedSubSize64_491
module m #(parameter A = 4'd3, parameter X = 1) (output logic [7:0] o);
localparam B = A - 4'd1; localparam C = B + X; assign o = C + 1;
endmodule
module top; logic [7:0] o;
m u(o); defparam u.X = 2;
endmodule
