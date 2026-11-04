// § ovUnsizedBasedActualForm491
module m #(parameter type T = int, parameter T A = 4) (output logic [7:0] o); assign o = A; endmodule
module top; logic [7:0] o; m #(.T(logic [7:0]), .A('h5)) u(o); endmodule
