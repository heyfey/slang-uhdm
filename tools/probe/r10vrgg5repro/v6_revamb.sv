// V3 -- Rggen's get_sub_n_list body VERBATIM (so the corrupted regime is the
// measured one), plus a SECOND packed array `other` written only at index 0.
// The function RETURNS `other`; the first `return` in source order names
// `list`.  slang's correct fold of the returned value is therefore already
// element-0-only at the instance's own width == the shared width (both
// instances are N=25), so the PRISTINE binary is RIGHT on this cell.
module v6_sub #(parameter int WIDTH = 2, parameter int N = 1) ();
  function automatic bit [N-1:0][15:0] get_sub_n_list(int n);
    bit [N-1:0][15:0] list;
    bit [N-1:0][15:0] other;
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

    other     = '0;
    other[0]  = 16'h0009;
    if (n > 1000) begin
      return other;
    end
    return list;
  endfunction

  function automatic int get_next_n(bit [N-1:0][15:0] sub_n_list);
    int next_n;
    next_n  = 0;
    for (int i = 0;i < N;++i) begin
      next_n  += ((sub_n_list[i] != 0) ? 1 : 0);
    end
    return next_n;
  endfunction

  localparam  bit [N-1:0][15:0] SUB_N_LIST  = get_sub_n_list(N);
  localparam  int               NEXT_N      = get_next_n(SUB_N_LIST);

  logic [NEXT_N-1:0][WIDTH-1:0] next_data;
endmodule
module top_v6_revamb;
  v6_sub #(.WIDTH(2), .N(25)) u00 ();
  v6_sub #(.WIDTH(2), .N(25)) u01 ();
endmodule
