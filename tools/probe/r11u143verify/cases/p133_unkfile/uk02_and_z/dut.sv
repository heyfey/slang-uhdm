// § unknownParamOperandFile133
// case uk02: a Z parameter under a bitwise and of a logic vector localparam
module top(output logic [7:0] o);
   parameter P = 'z;
   parameter Q = 8'hF0;
   localparam logic [7:0] C = P & Q;
   assign o = C;
endmodule
