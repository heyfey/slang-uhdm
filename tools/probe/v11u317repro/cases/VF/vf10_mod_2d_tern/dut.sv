// § modConnLeafVarSel317
module child (input logic d, output logic q);
  assign q = d;
endmodule
module top (input logic [1:0][1:0] m, input logic s, input logic a, output logic o);
  child c (.d(a ? m[s][0] : m[0][s]), .q(o));
endmodule
