// § modConnLeafVarSel317
module child (input logic d, output logic q);
  assign q = d;
endmodule
module top (input logic [1:0][1:0] m, input logic s, input logic t, output logic o);
  child c (.d($signed(m[s][t])), .q(o));
endmodule
