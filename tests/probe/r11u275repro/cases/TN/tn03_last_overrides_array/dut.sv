// § defNetTpDimLastInstPat275 — the last instance overrides the array parameter itself: the one before it wins
module child #(parameter type id_t = logic, parameter type rt_t = id_t [3:0]) (input logic [15:0] a, output logic [15:0] o);
  rt_t x;
  assign x = a;
  assign o = x;
endmodule
module dut (input logic [15:0] a, output logic [15:0] o1, o2);
  child #(.id_t(logic [1:0])) u1 (.a(a), .o(o1));
  child #(.rt_t(logic [5:0])) u2 (.a(a), .o(o2));
endmodule
