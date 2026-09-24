// § constCtxCallArgInner131v
// case i04: indexed part-select inside an operation that is a system-call argument
module sub #(parameter logic [15:0] A = 16'h00F0, parameter int P = $clog2(A[4 +: 8] + 1)) (output logic [7:0] o);
  assign o = P;
endmodule
module top(output logic [7:0] o);
  sub u(.o(o));
endmodule
