module dut(input logic [3:0] i, output logic [3:0] o);
  always_comb begin
    struct packed { logic a; logic b; } [1:0] t;
    t = i;
    o = t;
  end
endmodule
