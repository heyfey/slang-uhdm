// § nestedPosInstUdp307
module outer (input logic [1:0] a, output logic [1:0] y);
  module inner (output logic [1:0] o, input logic [1:0] i); assign o = i; endmodule
  inner u_in ({y[0], y[1]}, a);
endmodule
module dut (input logic [1:0] a, output logic [1:0] y);
  outer u1 (a, y);
endmodule
