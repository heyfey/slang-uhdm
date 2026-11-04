// § defNetTpPatNestedSig281
module child #(parameter int N = 2, parameter type id_t = logic, localparam type rt_t = id_t [3:0]) (input logic [7:0] a, output logic [7:0] o);
  rt_t x [N];
  for (genvar k = 0; k < N; k++) begin : g
    assign x[k] = a;
  end
  assign o = x[N-1];
endmodule
module dut(input logic [7:0] a, output logic [7:0] o);
  child #(.N(3), .id_t(logic [1:0])) u (.a(a), .o(o));
endmodule
