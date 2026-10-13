// § modConnLeafVarSel317
module child (input logic d, output logic q);
  assign q = d;
endmodule
module top (input logic [1:0][1:0] m, input logic s, input logic a, output logic o);
  if (1) begin : g
    child c (.d(m[s][0] & a), .q(o));
  end
endmodule
