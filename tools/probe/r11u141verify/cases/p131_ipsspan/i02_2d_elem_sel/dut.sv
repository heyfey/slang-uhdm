// § paramIdxPartSelWholeSpan131
// case i02: indexed part-select of an element of a 2-D packed parameter
module sub #(parameter logic [1:0][7:0] A = 16'h1234, parameter logic [3:0] P = A[1][4 +: 4]) (output logic [3:0] o);
  assign o = P;
endmodule
module top(output logic [3:0] o);
  sub u(.o(o));
endmodule
