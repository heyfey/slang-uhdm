// § typeParamStructLastNetParent273
module dut (input logic [5:0] i, output logic [5:0] o);
  localparam type T = struct packed { struct packed { logic [1:0] p; bit q; } s; logic [2:0] b; };
  T v;
  always_comb v = i;
  assign o = v;
endmodule
