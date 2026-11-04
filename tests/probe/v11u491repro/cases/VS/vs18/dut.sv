// § unboundedSubSize64_491
module m #(parameter A = 8'd3) (output logic [7:0] o);
localparam B = A - 4'd1; assign o = B + 1;
endmodule
module top; logic [7:0] o;
m u(o);
endmodule
