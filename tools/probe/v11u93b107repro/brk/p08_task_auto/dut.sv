module dut(input logic [3:0] i, output logic [3:0] o);
  logic [3:0] r;
  task automatic t(input logic [3:0] v, output logic [3:0] w);
    struct packed { logic a; logic b; } [1:0] z;
    z = v;
    w = z;
  endtask
  always_comb t(i, r);
  assign o = r;
endmodule
