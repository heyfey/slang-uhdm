// § ovUnsizedBasedActualForm491
module m #(parameter A = 4) (output logic [7:0] o);
logic [A:0] q; assign o = q;
endmodule
module top; logic [7:0] o;
m #(.A('h5)) u(o);
endmodule
