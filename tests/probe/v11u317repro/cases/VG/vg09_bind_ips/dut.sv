// § modConnIpsBaseByPort317
module child (input logic d, output logic q);
  assign q = d;
endmodule
module tgt (input logic [3:0] v, input logic [1:0] s, output logic o);
  assign o = v[0];
endmodule
module top (input logic [3:0] v, input logic [1:0] s, output logic o);
  tgt t (.v(v), .s(s), .o(o));
endmodule
bind tgt child cb (.d(v[s +: 1]), .q());
