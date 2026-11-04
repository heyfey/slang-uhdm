// § caInsideRhsClonesCell301
module dut (input logic [7:0] a, output logic o);
  assign o = a inside {8'd1, 8'd2, 8'd5};
endmodule
