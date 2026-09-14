package pk;
  typedef enum integer { PNone, PBal } p_e;
endpackage
module top import pk::*; #(parameter p_e P = PNone)
  (input logic [31:0] a, output logic [31:0] o2);
  assign o2 = (P != PNone) ? a : '0;
endmodule
