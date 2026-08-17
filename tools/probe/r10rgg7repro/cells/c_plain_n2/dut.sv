module sub #(
  parameter int N = 2
)(
  output logic o_result
);
  localparam int NEXT = 2;

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
  sub #(.N(2)) u0 (.o_result(r0));
endmodule
