package pk;
  typedef enum integer { PNone, PBal } p_e;
endpackage
module top import pk::*; #(parameter p_e P = PNone)
  (input logic [31:0] a, input logic [4:0] s, output logic [31:0] o2);
  if (0) begin : g1
    assign o2 = a;
  end else begin : g2
    assign o2 = (P != PNone) ? ~(32'hffff_ffff << s) : '0;
  end
endmodule
