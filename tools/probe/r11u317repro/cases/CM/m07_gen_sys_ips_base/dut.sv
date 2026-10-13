// § modConnIpsBaseByPort317
module child (input logic d, output logic q);
  assign q = d;
endmodule
module top (input logic [3:0] v, input logic [1:0] s, input logic t, output logic o);
  if (1) begin : g
    child c (.d(t ? v[s +: 1] : v[0]), .q(o));
  end
endmodule
