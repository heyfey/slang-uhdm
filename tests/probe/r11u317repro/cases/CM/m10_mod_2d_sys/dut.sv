// § modConnLeafVarSel317
module child (input logic d, output logic q);
  assign q = d;
endmodule
module top (input logic [3:0] v, input logic [1:0] s, input logic [1:0][1:0] m, input logic a, output logic o);
  child c (.d($signed(m[1][s])), .q(o));
endmodule
