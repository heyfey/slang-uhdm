// § bitNegTypedOperandSize491
module m #(parameter logic [7:0] A = 4'o4) (output logic [7:0] o);
localparam B = ~A; assign o = B;
endmodule
module top; logic [7:0] o;
m u(o);
endmodule
