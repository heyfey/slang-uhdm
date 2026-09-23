module dut #(parameter type id_t = logic [1:0], localparam type rt_t = id_t [3:0]) (output logic [7:0] o);
  if (1) begin : g
    rt_t x = 8'h5a;
    assign o = x;
  end
endmodule
