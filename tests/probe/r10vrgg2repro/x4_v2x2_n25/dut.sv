module orv #(
  parameter int WIDTH = 2,
  parameter int N     = 20
)(
  input   logic [N-1:0][WIDTH-1:0]  i_data,
  output  logic [WIDTH-1:0]         o_result
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
  function automatic bit [N-1:0][15:0] get_offset_list(bit [N-1:0][15:0] sub_n_list);
    bit [N-1:0][15:0] list;
    for (int i = 0;i < N;++i) begin
      if (i == 0) list[i] = 0;
      else        list[i] = sub_n_list[i-1] + list[i-1];
    end
    return list;
  endfunction
  localparam  bit [N-1:0][15:0] SUB_N_LIST  = get_sub_n_list(N);
  localparam bit [N-1:0][15:0] OFFSET_LIST = get_offset_list(SUB_N_LIST);
  assign o_result = SUB_N_LIST[0][WIDTH-1:0];
endmodule
