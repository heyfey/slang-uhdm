package pk;
  struct packed { logic a; logic b; } [1:0] pv;
endpackage
module dut(input logic [3:0] i, output logic [3:0] o);
  assign o = pk::pv ^ i;
endmodule
