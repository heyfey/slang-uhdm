module child #(
    parameter type id_t = logic,
    localparam type rt_t = id_t [3:0]
) (input logic [15:0] a, output logic o);
  if (1) begin : g
    rt_t x = 8'h0f;
    assign o = ^x ^ ^a;
  end
endmodule
module dut(input logic [15:0] a, output logic o);
  child #(.id_t(logic [1:0])) u (.a(a), .o(o));
endmodule
