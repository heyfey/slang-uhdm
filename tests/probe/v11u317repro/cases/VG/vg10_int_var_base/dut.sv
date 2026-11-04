// § modConnIpsBaseByPort317
module child (input logic d, output logic q);
  assign q = d;
endmodule
module top (input logic [3:0] v, output logic o);
  int i;
  assign i = 1;
  child c (.d(v[i +: 1]), .q(o));
endmodule
