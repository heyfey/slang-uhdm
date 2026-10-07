// § defNetTpDimLastInstPat275 — a non-local parameter type over the element
module child #(parameter type id_t = logic, parameter type rt_t = id_t [3:0]) (input logic [15:0] a, output logic [15:0] o);
  rt_t x;
  assign x = a;
  assign o = x;
endmodule
module dut (input logic [15:0] a, output logic [15:0] o);
  child #(.id_t(logic [1:0])) u (.a(a), .o(o));
endmodule
