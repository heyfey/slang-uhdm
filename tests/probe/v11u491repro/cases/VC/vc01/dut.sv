// § ovUnsizedBasedActualForm491
module m #(parameter logic [7:0] A = 4) (output logic [7:0] o, output logic [15:0] p);
assign o = A; assign p = A;
endmodule
module top; logic [7:0] o; logic [15:0] p; m #(.A('hFFF)) u(o, p); endmodule
