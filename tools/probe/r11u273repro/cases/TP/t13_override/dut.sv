// § typeParamStructLastNetParent273
typedef struct packed { logic [3:0] a; logic b; } pair_t;
module m #(parameter type T = struct packed { logic [1:0] c; }) (input logic [4:0] i, output logic [4:0] o);
  T s;
  always_comb s = i;
  assign o = s;
endmodule
module dut(input logic [4:0] i, output logic [4:0] o);
  m #(.T(pair_t)) u(.i(i), .o(o));
endmodule
