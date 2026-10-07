// § typeParamStructLastNetParent273
module dut (input logic [4:0] i, output logic [4:0] o);
  localparam type T = struct packed { logic [3:0] a; logic b; };
  T s1; T s2;
  always_comb begin s1 = i; s2 = s1; end
  assign o = s2;
endmodule
