module dut(input logic [7:0] i, output logic [7:0] o);
  for (genvar k = 0; k < 2; k++) begin : g
    struct packed { logic a; logic b; } [1:0] x;
    assign x = i[k*4 +: 4];
    assign o[k*4 +: 4] = x;
  end
endmodule
