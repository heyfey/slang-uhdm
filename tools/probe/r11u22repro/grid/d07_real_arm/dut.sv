package pk;
  typedef enum integer { PNone, PBal } p_e;
endpackage
module top import pk::*; #(parameter p_e P = PNone)
  (input logic [31:0] a, input logic [4:0] s, output real rv);
  if (1) begin : gb
    assign rv = (P == PNone) ? 1.5 : '0;
  end
endmodule
