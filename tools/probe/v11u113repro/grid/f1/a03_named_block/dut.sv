package pk; parameter int unsigned P = 5; endpackage
module top import pk::*; (input logic [7:0] i, output logic [7:0] o);
  always_comb begin : b
    logic [P:0] v;
    v = i[5:0];
    o = v;
  end
endmodule
