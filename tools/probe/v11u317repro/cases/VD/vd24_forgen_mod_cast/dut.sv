// § selIdxCastTsNamedBySel317
module child (input logic d, output logic q);
  assign q = d;
endmodule
module top (input logic [3:0] ck, input logic [2:0] s, output logic [1:0] o);
  for (genvar i = 0; i < 2; i++) begin : g
    child c (.d(ck[2'(s + i)]), .q(o[i]));
  end
endmodule
