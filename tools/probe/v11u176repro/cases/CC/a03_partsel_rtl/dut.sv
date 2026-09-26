// § castRhsClonePerInst176
module sub #(parameter W = 4) (input logic [W-1:0] i, output logic [7:0] o);
  assign o[3:0] = 4'(i + 1'b1);
  assign o[7:4] = 4'(i);
endmodule
module top (input logic [3:0] x, input logic [5:0] y, output logic [7:0] o1, output logic [7:0] o2);
  sub #(.W(4)) u1 (.i(x), .o(o1));
  sub #(.W(6)) u2 (.i(y), .o(o2));
endmodule
