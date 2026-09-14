package pk;
  typedef enum integer { PNone, PBal } p_e;
endpackage
interface ifc (input logic [31:0] a);
  logic [31:0] o2;
  assign o2 = a & 32'hff;
endinterface
module top (input logic [31:0] a);
  ifc u1 (.a(a));
endmodule
