// § caInsideRhsClonesCell301
module dut (input logic [3:0] a, b, output logic x, y, z);
  assign x = a inside {1};
  assign y = b inside {[0:2]};
  assign z = (a + b) inside {4};
endmodule
