module dut(input logic [3:0] i, input logic c, output logic [3:0] o);
  struct packed { logic a; logic b; } [1:0] x;
  assign x = i;
  assign o = {x[1].a, x[1].b, x[0].a, x[0].b};
endmodule
