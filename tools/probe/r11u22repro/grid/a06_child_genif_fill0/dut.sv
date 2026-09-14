package pk;
  typedef enum integer { PNone, PBal } p_e;
endpackage
module child import pk::*; #(parameter p_e P = PNone)
  (input logic [4:0] s, output logic [31:0] o2);
  if (1) begin : gb
    assign o2 = (P != PNone) ? ~(32'hffff_ffff << s) : '0;
  end
endmodule
module top (input logic [4:0] s, output logic [31:0] o2);
  child u1 (.s(s), .o2(o2));
endmodule
