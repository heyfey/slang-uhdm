package gp;
  function automatic int pcnt(bit [7:0][15:0] l);
    int r;
    r = 0;
    for (int i = 0;i < 8;++i) begin
      r += ((l[i] != 0) ? 1 : 0);
    end
    return r;
  endfunction
  localparam bit [7:0][15:0] PLIST = '{16'd1,16'd2,16'd3,16'd4,16'd5,16'd6,16'd7,16'd8};
endpackage

module leaf(output logic o);
  always_comb o = 1'b1;
endmodule

module sub #(
  parameter int N = 4
)(
  output logic o_result
);
  localparam int RAW = gp::pcnt(gp::PLIST);
  generate
    if ((N > 1) && (RAW > 1)) begin : g_reduce
      logic a_mark;
      always_comb begin
        a_mark = 1'b1;
      end
      sub #(.N(N - 1)) u_next (.o_result(o_result));
    end
    else begin : g_reduce
      logic b_mark;
      always_comb begin
        b_mark = 1'b1;
      end
      leaf u_leaf (.o(o_result));
    end
  endgenerate
endmodule

module top;
  logic r0;
  sub #(.N(4)) u0 (.o_result(r0));
endmodule
