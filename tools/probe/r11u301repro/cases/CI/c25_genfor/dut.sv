// § caInsideRhsClonesCell301
module dut (input logic [3:0] a, output logic [1:0] o);
  for (genvar i = 0; i < 2; i++) begin : g
    assign o[i] = a inside {[i:i+2]};
  end
endmodule
