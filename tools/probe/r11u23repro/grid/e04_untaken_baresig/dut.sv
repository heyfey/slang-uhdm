package pk;
  typedef enum integer { PNone, PBal } p_e;
endpackage
module top import pk::*; #(parameter p_e P = PNone)
  (input logic [31:0] a, input logic [4:0] s, output logic [31:0] o2);
  if (1) begin : gb
    logic [31:0] lv;
    assign lv = (P == PNone) ? '0 : a;
    assign o2 = lv;
  end
endmodule
