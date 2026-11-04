// § untypedDepUnboundedValue489
module m #(parameter A = 4'd15) (input logic [7:0] i, output logic [7:0] o);
localparam B = A + 4'd1; always_comb o = B + i;
endmodule
module top; logic [7:0] o;
m u(o, o);
endmodule
