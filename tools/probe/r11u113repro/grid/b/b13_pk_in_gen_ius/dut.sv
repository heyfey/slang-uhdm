package pk; parameter int unsigned P = 5; parameter int unsigned Q = 2; endpackage
module top import pk::*; (input logic [7:0] i, output logic [7:0] o);
  if (1) begin : g
    logic [P:0] x;
    assign x = i[5:0];
    assign o = x;
  end
endmodule
