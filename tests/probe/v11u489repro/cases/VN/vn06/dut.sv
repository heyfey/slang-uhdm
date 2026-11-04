// § dpDepBitNegUint489
module m #(parameter A = 4) (output logic [7:0] o);
localparam B = ~A; assign o = B;
endmodule
module top; logic [7:0] o;
logic [7:0] o2; m #(.A(3)) u1(o); m u2(o2);
endmodule
