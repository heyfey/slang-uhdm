module sub #(
  parameter int N = 1
)(
  output logic o_result
);
  function automatic int cnt(bit [0:0][15:0] l);
    int r;
    r = 0;
    for (int i = 0;i < 1;++i) begin
      r += ((l[i] != 0) ? 1 : 0);
    end
    return r;
  endfunction
  localparam bit [0:0][15:0] LIST = '{16'd1};
  localparam int NEXT = cnt(LIST);

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
  sub #(.N(1)) u0 (.o_result(r0));
endmodule
