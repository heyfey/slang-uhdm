package pk;
  typedef enum integer { PNone, PBal } p_e;
endpackage
module sub import pk::*; #(parameter p_e P = PNone) (input logic [4:0] s);
  if (1) begin : gb
    logic [31:0] lv;
    assign lv = (P != PNone) ? ~(32'hffff_ffff << s) : '0;
  end
endmodule
module top (input logic [4:0] s, output logic [31:0] o2);
  sub #(.P(pk::PNone)) u1 (.s(s));
  sub #(.P(pk::PBal))  u2 (.s(s));
  assign o2 = 32'd0;
endmodule
