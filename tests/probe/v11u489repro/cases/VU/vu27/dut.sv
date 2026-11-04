// § untypedDepUnboundedValue489
module m #(parameter A = 4'd15) (output logic [7:0] o);
localparam B = A + 4'd1; function automatic logic [7:0] f(); return B; endfunction assign o = f();
endmodule
module top; logic [7:0] o;
m u(o);
endmodule
