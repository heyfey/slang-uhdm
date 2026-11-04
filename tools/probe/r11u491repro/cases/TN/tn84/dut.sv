// § bitNegTypedOperandSize491
module m #(parameter logic [63:0] A = 4'hF) (output logic [7:0] o);
localparam B = ~A; assign o = B;
endmodule
module top; logic [7:0] o;
m u(o);
endmodule
