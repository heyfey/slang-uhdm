// § strLitContOwnerEnd224
module top(input logic a, output logic y, output logic [7:0] w);
  localparam string S = 1 ? "x" : "ab \
cd"; assign y = a;
  assign w = S.len();
endmodule
