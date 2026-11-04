// § dpDepBitNegUint489
module m #(parameter A = 4) (output logic [7:0] o);
localparam B = ~A; logic [B[3:0]:0] w; assign o = w;
endmodule
module top; logic [7:0] o;
m u(o);
endmodule
