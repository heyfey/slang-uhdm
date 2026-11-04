// § ovUnsizedBasedActualForm491
module m #(parameter A = 4) (output logic [7:0] o);
logic [7:0] q; always_comb q = A; assign o = q;
endmodule
module top; logic [7:0] o;
m #(.A('h5)) u(o);
endmodule
