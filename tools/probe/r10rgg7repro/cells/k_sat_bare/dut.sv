module sub #(
  parameter int N = 25
)(
  output logic o_result
);
  function automatic bit [N-1:0][15:0] get_sub_n_list(int n);
    bit [N-1:0][15:0] list;
    int               list_index;
    bit [15:0]        current_n;
    bit [15:0]        half_n;

    list        = '0;
    list_index  = 0;
    current_n   = 16'(n);
    while (current_n > 0) begin
      half_n  = current_n / 2;
      if ((current_n > 4) && (half_n <= 4)) begin
        list[list_index]  = half_n;
      end
      else if (current_n >= 4) begin
        list[list_index]  = 4;
      end
      else begin
        list[list_index]  = current_n;
      end

      current_n   -= list[list_index];
      list_index  += 1;
    end

    return list;
  endfunction
  function automatic int cnt(bit [N-1:0][15:0] l);
    int r;
    r = 0;
    for (int i = 0;i < N;++i) begin
      r += ((l[i] != 0) ? 1 : 0);
    end
    return r;
  endfunction
  localparam bit [N-1:0][15:0] LIST = get_sub_n_list(N);
  localparam int NEXT = cnt(LIST);

  generate
    if (NEXT) begin : g_reduce
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
  sub #(.N(25)) u0 (.o_result(r0));
endmodule
