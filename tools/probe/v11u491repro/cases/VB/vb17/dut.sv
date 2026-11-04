// § unboundedDepBesideDefparam491
module m #(parameter A = 4'd15, parameter X = 1) (output logic [7:0] o);
localparam B = A + 4'd1; wire [B:0] w; assign o = w;
endmodule
module top; logic [7:0] o;
m u(o); defparam u.X = 2;
endmodule
