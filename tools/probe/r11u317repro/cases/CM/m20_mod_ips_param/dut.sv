// § modConnIpsBaseByPort317
module child (input logic [1:0] d, output logic q);
  assign q = d[0];
endmodule
module top (input logic [7:0] v, input logic [1:0] s, input logic a, output logic [1:0] o);
  localparam int P = 3;
  child c (.d(v[P +: 2]), .q(o[0]));
endmodule
