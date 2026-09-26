// § castRhsClonePerInst176
module sub (input logic [3:0] i, output logic [7:0] o);
  assign o[7:0] = signed'(i);
endmodule
module top (input logic [3:0] x, output logic [7:0] o1, output logic [7:0] o2);
  sub u1 (.i(x), .o(o1));
  sub u2 (.i(x), .o(o2));
endmodule
