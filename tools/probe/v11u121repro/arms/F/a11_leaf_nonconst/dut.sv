module leaf #(parameter int N = 4, parameter type id_t = logic [$clog2(N)-1:0]) (input logic [3:0] r, output id_t o);
  for (genvar j = 0; j < 1; j++) begin : lv
    if (j == 0) begin : l0
      assign o = r[0] ? id_t'(r[3:2]) : id_t'({r[1], r[2]} ^ r[3]);
    end
  end
endmodule
