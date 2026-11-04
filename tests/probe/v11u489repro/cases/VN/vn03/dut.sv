// § dpDepBitNegUint489
module m #(parameter A = 4) (output logic [7:0] o);
localparam B = ~A; assign o = B + 1;
endmodule
module top; logic [7:0] o;
m u(o);
endmodule
