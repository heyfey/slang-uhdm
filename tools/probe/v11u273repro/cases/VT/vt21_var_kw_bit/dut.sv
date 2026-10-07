// § tpVarSigKeepsTpParent273v
module dut (input logic [4:0] i, output logic [4:0] o);
  localparam type T = struct packed { bit [3:0] a; bit b; };
  var T v;
  always_comb v = i;
  assign o = v;
endmodule
