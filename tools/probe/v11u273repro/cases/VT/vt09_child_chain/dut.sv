// § typeParamStructLastNetParent273
module c #(parameter type T = logic) (input T i, output T o);
  T r;
  always_comb r = i;
  assign o = r;
endmodule
module dut (input logic [4:0] i, output logic [4:0] o);
  localparam type T = struct packed { logic [3:0] a; logic b; };
  T s;
  always_comb s = i;
  c #(.T(T)) u(.i(s), .o(o));
endmodule
