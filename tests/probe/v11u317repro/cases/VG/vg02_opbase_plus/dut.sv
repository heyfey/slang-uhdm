// § modConnIpsBaseByPort317
module child2 (input logic [1:0] d, output logic q);
  assign q = d[0];
endmodule
module top (input logic [7:0] v, input logic [1:0] s, output logic o);
  child2 c (.d(v[s+1 +: 2]), .q(o));
endmodule
