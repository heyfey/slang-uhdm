// § bitNegTypedOperandSize491
module m #(parameter bit [7:0] A = 4'd4) (output logic [7:0] o);
localparam B = ~A; assign o = B;
endmodule
module mid(output logic [7:0] o); m u(o); endmodule
module top; logic [7:0] o; mid x(o); endmodule
