module dut(input struct packed { logic a; logic b; } [1:0] p, output logic [3:0] o);
  assign o = p;
endmodule
