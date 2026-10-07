// § defNetTpDimLastInstPat275 — a package typedef element override
package p;
  typedef logic [2:0] b_t;
endpackage
module child #(parameter type id_t = logic, localparam type rt_t = id_t [3:0]) (input logic [15:0] a, output logic [15:0] o);
  rt_t x;
  assign x = a;
  assign o = x;
endmodule
module dut (input logic [15:0] a, output logic [15:0] o);
  child #(.id_t(p::b_t)) u (.a(a), .o(o));
endmodule
