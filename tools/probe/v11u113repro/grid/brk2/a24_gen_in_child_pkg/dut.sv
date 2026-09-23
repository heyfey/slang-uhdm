package pk; parameter int unsigned P = 5; endpackage
module c import pk::*; (input logic [7:0] i, output logic [7:0] o);
  for (genvar k=0;k<2;k++) begin : g
    logic [P:0] x;
    assign x = i[5:0];
  end
  assign o = g[1].x;
endmodule
module top (input logic [7:0] i, output logic [7:0] o);
  c u(.i(i), .o(o));
endmodule
