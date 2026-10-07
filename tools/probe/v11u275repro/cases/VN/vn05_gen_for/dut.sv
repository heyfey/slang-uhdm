// § defNetTpDimLastInstPat275 — instances in a for-generate with genvar-dependent overrides
module child #(parameter type id_t = logic, localparam type rt_t = id_t [3:0]) (input logic [15:0] a, output logic [15:0] o);
  rt_t x;
  assign x = a;
  assign o = x;
endmodule
module dut (input logic [15:0] a, output logic [15:0] o [2]);
  for (genvar i = 0; i < 2; i++) begin : g
    child #(.id_t(logic [i+1:0])) u (.a(a), .o(o[i]));
  end
endmodule
