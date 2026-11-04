// § ovUnsizedBasedActualForm491
module m #(parameter int A = 4) (output logic [7:0] o);
localparam B = ~A; assign o = B;
endmodule
module top; logic [7:0] o;
m #(.A('h5)) u(o);
endmodule
