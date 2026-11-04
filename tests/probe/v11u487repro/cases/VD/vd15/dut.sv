// § dpDepPreDefparamValue487
module m #(parameter A = 4) (); localparam B = A + 1; logic [7:0] o; assign o = B; endmodule
module top; m u[1:0](); defparam u[0].A = 6; endmodule
