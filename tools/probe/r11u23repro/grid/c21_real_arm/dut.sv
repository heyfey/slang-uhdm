package pk;
  typedef enum integer { PNone, PBal } p_e;
endpackage
module top import pk::*; #(parameter p_e P = PNone)
  (input logic [31:0] a, input logic [4:0] s, output logic [31:0] o2);
  if (1) begin : gb
    real lv;
    assign lv = (P != PNone) ? 2.5 : 1.5;
  end
  assign o2 = a;
endmodule
