// § bitNegBareNameActual491
module m #(parameter A = 4) (output logic [7:0] o); localparam B = ~A; assign o = B; endmodule
module mid #(parameter P = 5) (output logic [7:0] o); m #(.A(P)) u(o); endmodule
module top; logic [7:0] o; mid x(o); defparam x.P = 9; endmodule
