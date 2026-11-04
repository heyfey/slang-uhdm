// § dpDepBitNegUint489
module m #(parameter A = 4) (output logic [7:0] o);
localparam B = ~A; logic [7:0] q; always_comb begin q = 0; if (B != 0) q = 1; end assign o = q;
endmodule
module top; logic [7:0] o;
m u(o);
endmodule
