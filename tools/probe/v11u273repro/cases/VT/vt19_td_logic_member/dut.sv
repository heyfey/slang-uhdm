// § typeParamStructLastNetParent273
module dut (input logic [4:0] i, output logic [4:0] o);
  typedef logic [3:0] nib_t;
  localparam type T = struct packed { nib_t a; logic b; };
  T s;
  always_comb s = i;
  assign o = s;
endmodule
