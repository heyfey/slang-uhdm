// § defNetTpDimLastInstPat275 — a variable (not net) declared with the type, always_comb driven
module child #(parameter type id_t = logic, localparam type rt_t = id_t [3:0]) (input logic [15:0] a, output logic [15:0] o);
  rt_t x;
  always_comb x = a;
  assign o = x;
endmodule
module dut (input logic [15:0] a, output logic [15:0] o);
  child #(.id_t(logic [1:0])) u (.a(a), .o(o));
endmodule
