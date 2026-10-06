// § shareDefParamTsOwnNotImport262 (instance depth 2, two instances with different overrides)
package fp;
  parameter int AddrW = 17;
endpackage
module er import fp::*; #(parameter int AddrW = 10) (output logic [7:0] q);
  assign q = AddrW;
endmodule
module mid(output logic [7:0] q, output logic [7:0] r);
  er #(.AddrW(5)) u1 (.q(q));
  er #(.AddrW(6)) u2 (.q(r));
endmodule
module top(output logic [7:0] q, output logic [7:0] r);
  mid m (.q(q), .r(r));
endmodule
