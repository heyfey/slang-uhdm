// § nestedPosInstUdp307
module outer (input logic a, output logic y);
  module inner (input logic [1:0] i, output logic o); assign o = ^i; endmodule
  inner u_in ({a, 1'b1}, y);
endmodule
module dut (input logic a, output logic y);
  outer u1 (.a(a), .y(y));
endmodule
