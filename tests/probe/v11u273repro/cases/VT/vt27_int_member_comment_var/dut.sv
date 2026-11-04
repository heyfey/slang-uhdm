// § tpVarSigKeepsTpParent273v
module dut (input logic [31:0] i, output logic [31:0] o);
  localparam type T = struct packed { int a; logic b; };
  /* var */ T s;
  always_comb s = {i, 1'b0};
  assign o = s.a;
endmodule
