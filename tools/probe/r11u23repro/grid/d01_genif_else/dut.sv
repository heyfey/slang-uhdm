package pk;
  typedef enum integer { PNone, PBal } p_e;
endpackage
module top import pk::*; #(parameter p_e P = PNone)
  (input logic [31:0] a, input logic [4:0] s, output logic [31:0] o2);
  if (0) begin : gb0
    assign o2 = a;
  end else begin : gb1
    logic [31:0] lv;
    assign lv = (P != PNone) ? ~(32'hffff_ffff << s) : '0;
    assign o2 = lv;
  end
endmodule
