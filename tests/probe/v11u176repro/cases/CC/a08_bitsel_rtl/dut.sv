// § castRhsClonePerInst176
module sub (input logic [3:0] i, output logic [3:0] o);
  assign o[0] = 1'(i[3]);
  assign o[3:1] = 3'(i);
endmodule
module top (input logic [3:0] x, output logic [3:0] y);
  sub u1 (.i(x), .o(y));
endmodule
