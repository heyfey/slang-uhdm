// § evalFuncUnreducedOperandKeepsCall287
parameter int UW = 3;
function automatic int f(int a); int r; r = a + UW; return r; endfunction
module m(output logic [31:0] o); assign o = f(5); endmodule
