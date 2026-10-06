// § shareDefParamTsOwnNotImport262 (overridden header parameter shadowing a package parameter, used as a net range: Earlgrey flash_erase_ctrl AddrW)
package fp;
  parameter int AddrW = 17;
endpackage
module er import fp::*; #(parameter int AddrW = 10, parameter int WordsPerPage = 256) (input logic [AddrW-1:0] a, output logic [AddrW-1:0] q);
  localparam logic [AddrW-1:0] Mask = '1;
  assign q = a & Mask;
endmodule
module top(input logic [16:0] a, output logic [16:0] q);
  er #(.AddrW(17), .WordsPerPage(256)) u (.a(a), .q(q));
endmodule
