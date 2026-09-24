package p;
  parameter int unsigned P = 32;
endpackage
module dut import p::*; ();
  logic clk;
  logic [63:0] v [4];
  task automatic t(output logic o); o = 1'b1; endtask
  for (genvar f = 0; f < 2; f++) begin : gf
    for (genvar b = 0; b < 2; b++) begin : gb
      always_comb t(v[f][P]);
    end
  end
endmodule
