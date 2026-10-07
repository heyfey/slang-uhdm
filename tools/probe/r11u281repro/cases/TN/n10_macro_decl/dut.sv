// § defNetTpPatNestedSig281
`define DECL(t, n) t n [2];
module child #(parameter type id_t = logic, localparam type rt_t = id_t [3:0]) (input logic [7:0] a, output logic [7:0] o);
  `DECL(rt_t, x)
  assign x[0] = a;
  assign x[1] = a;
  assign o = x[1];
endmodule
module dut(input logic [7:0] a, output logic [7:0] o);
  child #(.id_t(logic [1:0])) u (.a(a), .o(o));
endmodule
