// § shadowedImportParamFold
package fp;
  localparam int BankW = 1;
  localparam int PageW = 8;
  localparam int AddrW = BankW + PageW;
endpackage
module child #(
  parameter int AddrW = 10,
  parameter int Other = 3
) (
  input [AddrW-1:0] a_i,
  output logic [AddrW-1:0] a_o
);
  import fp::*;
  assign a_o = a_i;
endmodule
module top import fp::*; (input [AddrW-1:0] i, output [AddrW-1:0] o);
  child #(.AddrW(PageW), .Other(AddrW)) u_c (.a_i(i), .a_o(o));
endmodule
