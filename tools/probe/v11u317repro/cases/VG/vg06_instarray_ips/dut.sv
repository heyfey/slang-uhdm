// § modConnIpsBaseByPort317
module child (input logic d, output logic q);
  assign q = d;
endmodule
module top (input logic [3:0] v, input logic [1:0] s, output logic [1:0] o);
  child c [1:0] (.d(v[s +: 2]), .q(o));
endmodule
