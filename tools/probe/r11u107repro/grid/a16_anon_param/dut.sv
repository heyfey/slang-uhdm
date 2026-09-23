module dut(input logic [3:0] i, output logic [3:0] o);
  localparam struct packed { logic a; logic b; } [1:0] P = 4'b1010;
  assign o = i ^ P;
endmodule
