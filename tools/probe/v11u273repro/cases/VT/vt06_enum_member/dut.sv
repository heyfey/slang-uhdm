// § typeParamStructLastNetParent273
module dut (input logic [2:0] i, output logic [2:0] o);
  typedef enum logic [1:0] { E0, E1, E2 } e_t;
  localparam type T = struct packed { e_t k; logic b; };
  T s;
  always_comb s = i;
  assign o = s;
endmodule
