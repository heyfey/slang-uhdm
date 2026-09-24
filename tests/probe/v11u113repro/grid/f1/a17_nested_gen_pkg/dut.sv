package pk; parameter int unsigned P = 5; endpackage
module top import pk::*; (input logic [7:0] i, output logic [7:0] o);
  for (genvar k = 0; k < 1; k++) begin : g
    if (1) begin : h
      wire [P:0] x;
      assign x = i[5:0];
      assign o = x;
    end
  end
endmodule
