package pk;
  typedef enum integer { PNone, PBal } p_e;
endpackage
module top import pk::*; #(parameter p_e P = PNone)
  (input logic [31:0] a, input logic [4:0] s, output logic [31:0] o2);
  for (genvar g = 0; g < 2; g++) begin : gf
    logic [31:0] lv;
    assign lv = (P != PNone) ? ~(32'hffff_ffff << s) : '0;
  end
  assign o2 = gf[0].lv;
endmodule
