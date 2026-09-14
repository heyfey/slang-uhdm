package pk;
  typedef enum integer { PNone, PBal } p_e;
endpackage
module top import pk::*; #(parameter p_e P = PNone, parameter p_e Q = PBal)
  (input logic [31:0] a, input logic [4:0] s, output logic [31:0] o2);
  if (1) begin : gb
    assign o2 = (P == PNone) ? Q : '0;
  end
endmodule
