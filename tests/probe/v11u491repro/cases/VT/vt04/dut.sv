// § bitNegTypedOperandSize491
module m #(parameter bit [3:0] A = 8'd3) (output logic [7:0] o);
localparam B = ~A; assign o = B;
endmodule
module top; logic [7:0] o;
m u(o);
endmodule
