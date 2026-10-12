// § caInsideRhsClonesCell301
module dut (input logic [3:0] a, output logic [3:0] o);
  assign o = a inside {[4'd1:4'd2]};
endmodule
