// § dpDepBitNegUint489
module m #(parameter A = 4) (output logic [7:0] o);
localparam B = ~A; logic [7:0] q; always_comb q = (o == B) ? 8'd1 : 8'd0;
endmodule
module top; logic [7:0] o;
m u(o);
endmodule
