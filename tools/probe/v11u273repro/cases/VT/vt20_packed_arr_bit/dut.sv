// § typeParamStructLastNetParent273
module dut (input logic [9:0] i, output logic [9:0] o);
  localparam type T = struct packed { bit [3:0] a; bit b; };
  T [1:0] pa;
  always_comb pa = i;
  assign o = pa;
endmodule
