// § unboundedSubSize64_491
module m #(parameter A = 4'd3, parameter B = A - 4'd1) (output logic [7:0] o);
assign o = B + 1;
endmodule
module top; logic [7:0] o;
m u(o);
endmodule
