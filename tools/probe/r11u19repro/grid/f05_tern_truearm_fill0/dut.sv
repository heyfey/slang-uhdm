package pk;
  typedef enum integer { PNone, PBal } p_e;
endpackage
module top import pk::*; #(parameter p_e P = PBal)
  (input logic [31:0] a, input logic [4:0] s, output logic [31:0] o2);
  assign o2 = (P != PNone) ? '0 : ~(32'hffff_ffff << s);
endmodule
