// § modConnIpsBaseByPort317
module child (input logic d, output logic q);
  assign q = d;
endmodule
module top (input logic [3:0] v, input logic [1:0] s, output logic o);
  if (1) begin : g
    child c (.d(v[s +: 1]), .q(o));
  end
endmodule
