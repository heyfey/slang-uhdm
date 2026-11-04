// § modConnIpsBaseByPort317
module child (input logic d, output logic q);
  assign q = d;
endmodule
module top (input logic [3:0] v, input logic [2:0] s, output logic o);
  child c (.d(v[2'(s) +: 1]), .q(o));
endmodule
