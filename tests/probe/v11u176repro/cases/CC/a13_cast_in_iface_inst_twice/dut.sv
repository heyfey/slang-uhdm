// § castRhsClonePerInst176
module sub #(parameter Y = 3) (output logic [7:0] o);
  assign o[3:0] = 4'(Y);
  assign o[7:4] = 4'(Y + 1);
endmodule
module mid #(parameter Z = 1) (output logic [7:0] o);
  sub #(.Y(Z)) s (.o(o));
endmodule
module top (output logic [7:0] o1, o2);
  mid #(.Z(2)) m1 (.o(o1));
  mid #(.Z(5)) m2 (.o(o2));
endmodule
