// § bitNegTypedOperandSize491
module m #(parameter integer A = 4) (output logic [7:0] o);
localparam B = ~A; assign o = B;
endmodule
module top; logic [7:0] o;
m #(.A('d5)) u(o);
endmodule
