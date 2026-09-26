// § castRhsClonePerInst176
module sub #(parameter Y = 3) (output logic [7:0] o);
  assign o[7:0] = 8'(Y);
endmodule
module top #(parameter M = 1) (output logic [7:0] o1, o2);
  if (M == 1) begin : gi
    sub #(.Y(4)) u (.o(o1));
  end
  sub #(.Y(9)) u2 (.o(o2));
endmodule
