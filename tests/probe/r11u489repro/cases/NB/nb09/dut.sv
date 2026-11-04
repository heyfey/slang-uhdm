// § dpDepBitNegUint489
module m #(parameter A = 4) (output logic [7:0] o); localparam B = ~A; assign o = B; endmodule
module top; logic [7:0] o, p; m #(.A(5)) u(o); m #(.A(9)) v(p); endmodule
