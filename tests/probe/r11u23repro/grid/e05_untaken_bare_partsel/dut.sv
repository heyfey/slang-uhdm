package pk;
  typedef enum integer { PNone, PBal } p_e;
endpackage
module top import pk::*; #(parameter p_e P = PNone)
  (input logic [31:0] a, input logic [4:0] s, output logic [31:0] o2);
  if (1) begin : gb
    logic [7:0] lv;
    assign lv = (P == PNone) ? 8'd5 : a[7:0];
    assign o2 = {24'd0, lv};
  end
endmodule
