// § defNetTpDimLastInstPat275 — a chained type parameter T2 = rt_t
module child #(parameter type id_t = logic, localparam type rt_t = id_t [3:0], parameter type T2 = rt_t) (input logic [7:0] a, output logic [7:0] o);
  T2 x;
  assign x = a;
  assign o = x;
endmodule
module dut (input logic [7:0] a, output logic [7:0] o);
  child #(.id_t(logic [1:0])) u (.a(a), .o(o));
endmodule
