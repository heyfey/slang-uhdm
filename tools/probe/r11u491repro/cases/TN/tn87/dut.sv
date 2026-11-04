// § bitNegTypedOperandSize491
module m #(parameter int A = 4'd4) (output logic [7:0] o);
localparam B = ~A; assign o = B;
endmodule
module top; logic [7:0] o;
m #(.A(8'hF)) u(o);
endmodule
