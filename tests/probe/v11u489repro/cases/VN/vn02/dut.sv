// § dpDepBitNegUint489
module m #(parameter A = 4) (output logic [7:0] o);
localparam B = ~A; sub s(.x(o), .i(B));
endmodule
module top; logic [7:0] o;
m u(o);
endmodule
module sub(output logic [7:0] x, input logic [31:0] i); assign x = i[7:0]; endmodule
