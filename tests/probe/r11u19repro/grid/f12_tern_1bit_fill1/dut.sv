package pk;
  typedef enum integer { PNone, PBal } p_e;
endpackage
module top import pk::*; #(parameter p_e P = PNone)
  (input logic [31:0] a, input logic [4:0] s, output logic o1);
  assign o1 = (P != PNone) ? (a == 32'd7) : '1;
endmodule
