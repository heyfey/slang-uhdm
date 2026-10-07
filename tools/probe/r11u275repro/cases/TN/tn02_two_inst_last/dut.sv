// § defNetTpDimLastInstPat275 — two instances, the last one's element wins
module child #(parameter type id_t = logic, localparam type rt_t = id_t [3:0]) (input logic [15:0] a, output logic [15:0] o);
  rt_t x;
  assign x = a;
  assign o = x;
endmodule
module dut (input logic [15:0] a, output logic [15:0] o1, o2);
  child #(.id_t(logic [1:0])) u1 (.a(a), .o(o1));
  child #(.id_t(logic [3:0])) u2 (.a(a), .o(o2));
endmodule
