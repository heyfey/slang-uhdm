// § nestedPosInstUdp307
module outer (input logic [3:0] a, output logic [3:0] y);
  module inner (output logic [3:0] o, input logic [3:0] i); assign o = ~i; endmodule
  inner u_in (y, a);
endmodule
module dut (input logic [3:0] a, output logic [3:0] y);
  outer u1 (a, y);
endmodule
