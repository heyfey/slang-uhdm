// § ovUnsizedBasedActualForm491
module m #(parameter   A = 4) (output logic [7:0] o);
logic [7:0] r; always_comb r = A; assign o = r;
endmodule
module top; logic [7:0] o;
m #(.A('h5)) u(o);
endmodule
