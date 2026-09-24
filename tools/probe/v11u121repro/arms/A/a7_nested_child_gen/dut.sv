module leaf #(parameter int N = 2, parameter type id_t = logic [$clog2(N)-1:0]) (input logic [3:0] r, output id_t o);
  for (genvar j = 0; j < 1; j++) begin : lv
    if (j == 0) begin : l0
      assign o = r[0] ? id_t'(0) : id_t'({r[1], r[2]} ^ r[3]);
    end
  end
endmodule
module top (input logic [3:0] r, output logic [1:0] o1, output logic [2:0] o2);
  leaf #(.N(4)) u4 (.r(r), .o(o1));
  leaf #(.N(8)) u8 (.r(r), .o(o2));
endmodule
