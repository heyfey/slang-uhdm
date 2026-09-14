package pk;
  typedef enum integer { PNone, PBal } p_e;
endpackage
module top import pk::*; #(parameter p_e P = PNone)
  (input logic [31:0] a, input logic [4:0] s, output logic [15:0] o8);
  if (1) begin : gb
    assign o8 = (P == PNone) ? {<<8{16'habcd}} : '0;
  end
endmodule
