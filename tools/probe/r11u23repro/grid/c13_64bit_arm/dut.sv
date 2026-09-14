package pk;
  typedef enum integer { PNone, PBal } p_e;
endpackage
module top import pk::*; #(parameter p_e P = PNone)
  (input logic [31:0] a, input logic [4:0] s, output logic [63:0] o2);
  if (1) begin : gb
    logic [63:0] lv;
    assign lv = (P != PNone) ? {a, a} : 64'hffff_ffff_ffff_ffff;
    assign o2 = lv;
  end
endmodule
