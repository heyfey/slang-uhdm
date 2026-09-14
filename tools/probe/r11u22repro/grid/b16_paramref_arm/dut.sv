package pk;
  typedef enum integer { PNone, PBal } p_e;
endpackage
module top import pk::*; #(parameter p_e P = PNone, parameter int K = 9)
  (input logic [31:0] a, input logic [4:0] s, output logic [31:0] o2);
  if (1) begin : gb
    assign o2 = (P == PNone) ? K : '0;
  end
endmodule
