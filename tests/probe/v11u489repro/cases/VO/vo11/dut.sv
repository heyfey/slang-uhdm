// § ovSizedActualSize489
module m #(parameter A = 4'd15) (output logic [7:0] o);
sub s(.x(o), .i(A));
endmodule
module top; logic [7:0] o;
m #(.A(8'hAB)) u(o);
endmodule
module sub(output logic [7:0] x, input logic [7:0] i); assign x = i; endmodule
