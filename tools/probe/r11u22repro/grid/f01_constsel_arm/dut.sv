package pk;
  typedef enum integer { PNone, PBal } p_e;
endpackage
module top import pk::*; #(parameter p_e P = PNone,
    parameter logic [1:0][15:0] PA = 32'h0003_0004)
  (input logic [31:0] a, input logic [4:0] s, output logic [15:0] o16);
  if (1) begin : gb
    assign o16 = (P == PNone) ? PA[1] : '0;
  end
endmodule
