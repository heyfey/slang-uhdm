package grid_pkg;
  function automatic int pkg_cnt();
    bit [7:0][15:0] l;
    int r;
    l = '0;
    r = 0;
    for (int i = 0;i < 8;++i) begin
      r += ((l[i] != 0) ? 1 : 0);
    end
    r += 8;
    return r;
  endfunction
endpackage

module sub #(
  parameter int N = 8
)(
  output logic o_result
);
  localparam int NEXT = grid_pkg::pkg_cnt();

  generate
    if (NEXT > 1) begin : g_reduce
      logic a_mark;
      always_comb begin
        a_mark = 1'b1;
      end
    end
    else begin : g_reduce
      logic b_mark;
      always_comb begin
        b_mark = 1'b0;
      end
    end
  endgenerate
endmodule

module top;
  logic r0;
  sub #(.N(8)) u0 (.o_result(r0));
endmodule
