// § ovDefparamMaskWidth487
module m #(parameter logic [3:0] A = 4) (output logic [7:0] o); localparam B = A + 1; assign o = B; endmodule
module top; logic [7:0] o; m u(o); defparam u.A = 20; endmodule
