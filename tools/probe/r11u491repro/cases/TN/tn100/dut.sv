// § bitNegTypedOperandSize491
module m #(parameter integer A = 40'hFFFFFFFFF) (output logic [7:0] o);
localparam B = ~A; assign o = B;
endmodule
module top; logic [7:0] o;
m u(o);
endmodule
