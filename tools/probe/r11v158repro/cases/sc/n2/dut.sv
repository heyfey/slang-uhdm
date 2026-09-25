// § sizeCastNarrowTargetAbstain158v
module dut (output logic [1:0] p);
  localparam int W = 4;
  assign p = W'(13);
endmodule
