// § constCtxCallArgInner131v
// case i05: indexed part-select in the ELSE of a ternary nested in the THEN of another
module sub #(parameter logic [15:0] A = 16'h00F0, parameter int W = 1,
             parameter logic [7:0] P = (W > 0) ? ((W > 5) ? 8'h0 : A[4 +: 8]) : 8'h1) (output logic [7:0] o);
  assign o = P;
endmodule
module top(output logic [7:0] o);
  sub u(.o(o));
endmodule
