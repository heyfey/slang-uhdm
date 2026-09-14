package pk;
  typedef enum integer { PNone, PBal } p_e;
endpackage
module sub (input logic [31:0] a);
  logic [31:0] iv;
  assign iv = a;
endmodule
module top import pk::*; #(parameter p_e P = PNone)
  (input logic [31:0] a, input logic [4:0] s, output logic [31:0] o2);
  sub u1 (.a(a));
  if (1) begin : gb
    logic [31:0] lv;
    assign lv = (P != PNone) ? ~(32'hffff_ffff << s) : u1.iv;
    assign o2 = lv;
  end
endmodule
