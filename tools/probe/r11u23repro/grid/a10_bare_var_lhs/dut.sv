package pk;
  typedef enum integer { PNone, PBal } p_e;
endpackage
module top import pk::*; #(parameter p_e P = PNone)
  (input logic [31:0] a, input logic [4:0] s, output logic [31:0] o2);
  var bv;
  assign o2 = {31'd0, bv};
  if (1) begin : gb
    assign bv = (P != PNone) ? s[0] : '0;
  end
endmodule
