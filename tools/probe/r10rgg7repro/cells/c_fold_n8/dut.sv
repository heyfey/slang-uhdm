module sub #(
  parameter int N = 8
)(
  output logic o_result
);
  function automatic int addup(int n);
    int r;
    r = 0;
    for (int i = 0;i < n;++i) begin
      r += 1;
    end
    return r;
  endfunction
  localparam int NEXT = addup(8);

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
