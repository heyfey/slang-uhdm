// § modConnIpsBaseByPort317
module child (input logic d, output logic q);
  assign q = d;
endmodule
module top (input logic [3:0] v, output logic o);
  localparam int L = 1;
  child c (.d(v[L +: 1]), .q(o));
endmodule
