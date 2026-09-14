package pk;
  typedef enum integer { PNone, PBal } p_e;
endpackage
interface ifc import pk::*; #(parameter p_e P = PNone) (input logic [4:0] s);
  logic [31:0] o2;
  assign o2 = (P != PNone) ? ~(32'hffff_ffff << s) : '0;
endinterface
module top (input logic [4:0] s);
  ifc u1 (.s(s));
endmodule
