module dut(output logic [3:0] o);
  localparam struct packed { logic a; logic b; } [1:0] P = 4'b1001;
  assign o = P;
endmodule
