// § untypedDepUnboundedValue489
module m #(parameter A = 4'd15) (output logic [7:0] o);
localparam B = A + 4'd1; if (B == 16) begin : g assign o = 1; end else begin : h assign o = 2; end
endmodule
module top; logic [7:0] o;
m u(o);
endmodule
