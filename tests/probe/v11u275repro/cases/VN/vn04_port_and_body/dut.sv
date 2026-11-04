// § defNetTpDimLastInstPat275 — a port and a body net of the type
module child #(parameter type id_t = logic, localparam type rt_t = id_t [3:0]) (input rt_t a, output logic [15:0] o);
  rt_t x;
  assign x = a;
  assign o = 16'(x);
endmodule
module dut (input logic [7:0] a, output logic [15:0] o);
  child #(.id_t(logic [1:0])) u (.a(a), .o(o));
endmodule
