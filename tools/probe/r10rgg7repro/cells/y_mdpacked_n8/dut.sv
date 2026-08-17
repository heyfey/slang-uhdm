module sub #(
  parameter int N = 8
)(
  output logic o_result
);
  function automatic bit [7:0][15:0] mkfold();
    bit [7:0][15:0] l;
    for (int i = 0;i < 8;++i) begin
      l[i] = 16'd2;
    end
    return l;
  endfunction
  localparam bit [7:0][15:0] QQ = mkfold();

  generate
    if (QQ[0] > 1) begin : g_reduce
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
