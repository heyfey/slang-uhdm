// § defNetTpDimLastInstPat275 — the last instance by depth-first or breadth-first order
module child #(parameter type id_t = logic, localparam type rt_t = id_t [3:0]) (input logic [15:0] a, output logic [15:0] o);
  rt_t x;
  assign x = a;
  assign o = x;
endmodule
module mid (input logic [15:0] a, output logic [15:0] o);
  child #(.id_t(logic [2:0])) c (.a(a), .o(o));
endmodule
module dut (input logic [15:0] a, output logic [15:0] o1, o2);
  mid m (.a(a), .o(o1));
  child #(.id_t(logic [1:0])) c1 (.a(a), .o(o2));
endmodule
