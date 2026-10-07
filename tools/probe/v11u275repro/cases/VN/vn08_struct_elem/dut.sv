// § defNetTpDimLastInstPat275 — a struct element override
package p;
  typedef struct packed { logic [1:0] a; } s_t;
endpackage
module child #(parameter type id_t = logic, localparam type rt_t = id_t [3:0]) (input logic [15:0] a, output logic [15:0] o);
  rt_t x;
  assign x = a;
  assign o = x;
endmodule
module dut (input logic [15:0] a, output logic [15:0] o);
  child #(.id_t(p::s_t)) u (.a(a), .o(o));
endmodule
