module dut(input logic [3:0] i, output logic [3:0] o);
  if (1) begin : g
    struct packed { logic a; logic b; } [1:0] x;
    assign x = i;
    assign o = x;
  end
endmodule
