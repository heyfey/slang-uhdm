// § dpDepBitNegUint489
module m #(parameter A = 4) (output logic [7:0] o);
localparam B = ~A; localparam C = B; assign o = C;
endmodule
module top; logic [7:0] o;
m u(o);
endmodule
