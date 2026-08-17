package grid_pkg;
  localparam int PKG_N = 8;
endpackage

module sub #(
  parameter int N = 8
)(
  output logic o_result
);
  localparam int NEXT = grid_pkg::PKG_N;

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
