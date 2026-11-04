// § dpDepBitNegUint489
module m #(parameter A = 4) (output logic [7:0] o);
localparam B = ~A; assign o = B;
endmodule
module top; logic [7:0] o;
m #(.A(8'hF0)) u(o);
endmodule
