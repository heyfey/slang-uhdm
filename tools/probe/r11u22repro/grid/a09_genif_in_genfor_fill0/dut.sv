package pk;
  typedef enum integer { PNone, PBal } p_e;
endpackage
module top import pk::*; #(parameter p_e P = PNone)
  (input logic [31:0] a, input logic [4:0] s, output logic [31:0] o2);
  for (genvar i = 0; i < 1; i++) begin : gf
    if (1) begin : gi
      assign o2 = (P != PNone) ? ~(32'hffff_ffff << s) : '0;
    end
  end
endmodule
