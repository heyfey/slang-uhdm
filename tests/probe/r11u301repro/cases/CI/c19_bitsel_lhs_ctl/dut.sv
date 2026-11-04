// § caInsideRhsClonesCell301
module dut (input logic [3:0] a, output logic [1:0] o);
  assign o[0] = a inside {[4'd2:4'd6]};
  assign o[1] = 1'b1;
endmodule
