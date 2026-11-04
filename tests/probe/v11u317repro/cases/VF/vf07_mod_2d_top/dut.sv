// § modConnLeafVarSel317
module child (input logic d, output logic q);
  assign q = d;
endmodule
module top (input logic [1:0][1:0] m, input logic s, output logic o);
  child c (.d(m[s][0]), .q(o));
endmodule
