package pk;
  typedef enum integer { PNone, PBal } p_e;
endpackage
module top import pk::*; #(parameter p_e P = PNone)
  (input logic [31:0] a, input logic [4:0] s, output logic [71:0] ow);
  if (1) begin : gb
    assign ow = (P != PNone) ? {40'd0, a} : '1;
  end
endmodule
