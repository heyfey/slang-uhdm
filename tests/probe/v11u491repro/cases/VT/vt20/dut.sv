// § bitNegTypedOperandSize491
module m #(parameter bit A = 1'b0) (output logic [7:0] o);
localparam B = ~A; assign o = B;
endmodule
module top; logic [7:0] o;
m u(o);
endmodule
