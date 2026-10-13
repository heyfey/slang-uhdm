// § selIdxCastTsNamedBySel317
module child (input logic d, output logic q);
  assign q = d;
endmodule
module top (input logic [3:0] ck, input logic [2:0] s, output logic o);
  if (1) begin : g
    child c (.d(ck[2'(s)]), .q(o));
  end
endmodule
