// § sizeCastNarrowTargetAbstain158v
module dut (output logic [1:0] p, output logic [2:0] q);
  localparam int V = 7;
  assign p = 4'(V + 6);
  assign q = 6'(-V);
endmodule
