// § unboundedDepBesideDefparam491
module m #(parameter A = 4'd15, parameter X = 1) (output logic [7:0] o);
localparam B = $clog2(A) + 4'd1; assign o = B;
endmodule
module top; logic [7:0] o;
m u(o); defparam u.X = 2;
endmodule
