// § ovUnsizedBasedActualForm491
module m #(parameter A = 4) (output logic [7:0] o);
wire [7:0] w = A; assign o = w;
endmodule
module top; logic [7:0] o;
m #(.A('h5)) u(o);
endmodule
