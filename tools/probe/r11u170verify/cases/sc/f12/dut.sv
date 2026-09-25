// § sizeCastNarrowTargetAbstain158v
module dut (output logic [1:0] p, output logic q, output logic [2:0] r);
  localparam int V = 5;
  assign p = 3'(V + 1);
  assign q = 2'(3'd6);
  assign r = 4'(15 - 2);
endmodule
