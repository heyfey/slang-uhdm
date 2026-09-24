// § unknownParamOperandFile133
// case uk06: a typed 4-state X parameter under an xor
module top(output logic [3:0] o);
   parameter logic [3:0] P = 'x;
   localparam logic [3:0] C = P ^ 4'h3;
   assign o = C;
endmodule
