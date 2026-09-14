package pk;
  typedef enum integer { PNone, PBal } p_e;
endpackage
module top import pk::*; #(parameter p_e P = PNone)
  (input logic [31:0] a, input logic [4:0] s, output logic [71:0] o2);
  if (1) begin : gb
    logic [71:0] lv;
    assign lv = (P != PNone) ? {a, a, 8'd0} : 72'h1_0000_0000_0000_0000;
    assign o2 = lv;
  end
endmodule
