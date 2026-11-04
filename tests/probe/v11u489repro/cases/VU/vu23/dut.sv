// § untypedDepUnboundedValue489
module m #(parameter A = 4'd15) (input logic [7:0] i, output logic [7:0] o);
localparam B = 4'd15 + 4'd1; always_comb begin case (i) B: o = 1; default: o = 0; endcase end
endmodule
module top; logic [7:0] o, i; m u(i, o); endmodule
