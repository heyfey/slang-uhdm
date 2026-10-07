// § tpVarSigKeepsTpParent273v
module dut (input logic [4:0] i, output logic [4:0] o);
  localparam type T = struct packed { logic [3:0] a; logic b; };
  localparam type U = struct packed { bit [3:0] a; bit b; };
  T s;
  U t;
  always_comb begin s = i; t = s; end
  assign o = t;
endmodule
