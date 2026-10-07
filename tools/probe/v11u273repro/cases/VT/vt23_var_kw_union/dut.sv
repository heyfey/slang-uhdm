// § tpVarSigKeepsTpParent273v
module dut (input logic [7:0] i, output logic [7:0] o);
  localparam type T = union packed { logic [7:0] a; logic [7:0] b; };
  var T u;
  always_comb u = i;
  assign o = u.b;
endmodule
