// § connReplTsRefThroughPort137
// case rp01: control, a replication of a NET (not folded) as the actual
module sub(input logic [3:0] m, output logic [3:0] o); assign o = m; endmodule
module top(input logic a, output logic [3:0] o);
  sub u(.m({4{a}}), .o(o));
endmodule
