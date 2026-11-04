// § connReplTsRefThroughPort137
// case rp04: a constant replication actual to a non-ANSI child port
module sub(m, o);
  input [7:0] m;
  output [7:0] o;
  assign o = m;
endmodule
module top(output logic [7:0] o);
  sub u(.m({2{4'hA}}), .o(o));
endmodule
