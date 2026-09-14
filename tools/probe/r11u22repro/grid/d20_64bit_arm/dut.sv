package pk;
  typedef enum integer { PNone, PBal } p_e;
endpackage
module top import pk::*; #(parameter p_e P = PNone)
  (input logic [31:0] a, input logic [4:0] s, output logic [63:0] o64);
  if (1) begin : gb
    assign o64 = (P == PNone) ? 64'hffff_ffff_ffff_ffff : '0;
  end
endmodule
