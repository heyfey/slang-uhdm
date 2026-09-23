module dut(input logic [3:0] i, output logic [3:0] o);
  for (genvar g = 0; g < 1; g++) begin : gb
    struct packed { logic a; logic b; } [1:0] x;
    assign x = i;
    assign o = x;
  end
endmodule
