// § shareDefParamTsOwnNotImport262 (header localparam reading a shadowed overridden header parameter through $clog2: Earlgrey flash_mp BankW)
package fp;
  localparam int NumBanks = 2;
  localparam int BankW = $clog2(NumBanks);
endpackage
module er import fp::*; #(parameter int NumBanks = 4, localparam int BankW = $clog2(NumBanks)) (input logic [7:0] a, output logic [7:0] q);
  assign q = a;
endmodule
module top(input logic [7:0] a, output logic [7:0] q);
  er #(.NumBanks(2)) u (.a(a), .q(q));
endmodule
