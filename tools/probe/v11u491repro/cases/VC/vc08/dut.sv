// § ovUnsizedBasedActualForm491
module m #(parameter int A = 4) (output logic [7:0] o); function automatic int f(int x); return x + A; endfunction assign o = f(1); endmodule
module top; logic [7:0] o; m #(.A('h5)) u(o); endmodule
