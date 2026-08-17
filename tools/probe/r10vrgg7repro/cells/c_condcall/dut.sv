module sub #(
  parameter int N = 8
)(
  output logic o_result
);
  function automatic int cnt(bit [7:0][15:0] l);
    int r;
    r = 0;
    for (int i = 0;i < 8;++i) begin
      r += ((l[i] != 0) ? 1 : 0);
    end
    return r;
  endfunction
  localparam bit [7:0][15:0] LIST = '{16'd1,16'd2,16'd3,16'd4,16'd5,16'd6,16'd7,16'd8};
  function automatic int addup(int n);
    int r;
    r = 0;
    for (int i = 0;i < n;++i) begin
      r += 1;
    end
    return r;
  endfunction
  localparam int RAW = cnt(LIST);
  logic dummy;
  always_comb dummy = (RAW != 0);
  generate
    if (addup(8) > 1) begin : g_reduce
      logic a_mark;
      always_comb begin
        a_mark = 1'b1;
      end
    end
    else begin : g_reduce
      logic b_mark;
      always_comb begin
        b_mark = 1'b1;
      end
    end
  endgenerate
endmodule

module top;
  logic r0;
  sub #(.N(8)) u0 (.o_result(r0));
endmodule
