package pk;
  typedef enum integer { PNone, PBal } p_e;
endpackage
module top import pk::*; #(parameter p_e P = PNone)
  (input logic [31:0] a, input logic [4:0] s, output logic [31:0] o2);
  if (1) begin : gb
    assign o2 = (P == PNone) ? {24'd0, a[7:0]} : '0;
  end
endmodule
