// § untypedDepUnboundedValue489
module m #(parameter A = 4'd15) (output logic [7:0] o);
localparam B = A + 4'd1; sub #(.X(B)) s(o);
endmodule
module top; logic [7:0] o;
m u(o);
endmodule
module sub #(parameter X = 1) (output logic [7:0] o); assign o = X; endmodule
