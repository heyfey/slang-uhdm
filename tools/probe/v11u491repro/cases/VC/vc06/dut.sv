// § ovUnsizedBasedActualForm491
module m #(parameter logic [7:0] A = 4) (output logic [7:0] o); localparam B = A + 1; assign o = B; endmodule
module top; logic [7:0] o; m #(.A('hFFF)) u(o); endmodule
