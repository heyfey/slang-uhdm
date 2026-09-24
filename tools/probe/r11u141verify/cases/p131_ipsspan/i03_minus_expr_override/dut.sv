// § paramIdxPartSelWholeSpan131
// case i03: -: with an expression base in a parameter override
module sub #(parameter logic [3:0] P = 4'h0) (output logic [3:0] o);
  assign o = P;
endmodule
module top #(parameter logic [15:0] A = 16'h5A3C, parameter int K = 1) (output logic [3:0] o);
  sub #(.P(A[K*4+7 -: 4])) u(.o(o));
endmodule
