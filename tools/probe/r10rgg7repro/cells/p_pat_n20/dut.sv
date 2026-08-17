module sub #(
  parameter int N = 20
)(
  output logic o_result
);
  function automatic int cnt(bit [19:0][15:0] l);
    int r;
    r = 0;
    for (int i = 0;i < 20;++i) begin
      r += ((l[i] != 0) ? 1 : 0);
    end
    return r;
  endfunction
  localparam bit [19:0][15:0] LIST = '{16'd1,16'd2,16'd3,16'd4,16'd5,16'd6,16'd7,16'd8,16'd9,16'd10,16'd11,16'd12,16'd13,16'd14,16'd15,16'd16,16'd17,16'd18,16'd19,16'd20};
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
  sub #(.N(20)) u0 (.o_result(r0));
endmodule
