package p;
  function automatic bit [24:0][15:0] get_sub_n_list(int n);
    bit [24:0][15:0] list;
    int list_index;
    bit [15:0] current_n;
    list = '0;
    list_index = 0;
    current_n = 16'(n);
    while (current_n > 0) begin
      if (current_n >= 4) list[list_index] = 4;
      else                list[list_index] = current_n;
      current_n -= list[list_index];
      list_index += 1;
    end
    return list;
  endfunction
  function automatic int get_next_n(bit [24:0][15:0] sub_n_list);
    int next_n;
    next_n = 0;
    for (int i = 0;i < 25;++i) next_n += ((sub_n_list[i] != 0) ? 1 : 0);
    return next_n;
  endfunction
endpackage
module orv #(
  parameter int WIDTH = 2,
  parameter int N     = 20
)(
  input   logic [N-1:0][WIDTH-1:0]  i_data,
  output  logic [WIDTH-1:0]         o_result
);
  localparam bit [24:0][15:0] SUB_N_LIST = p::get_sub_n_list(25);
  localparam int NEXT_N = p::get_next_n(SUB_N_LIST);
  logic [NEXT_N:0] d;
  assign o_result = SUB_N_LIST[0][WIDTH-1:0];
endmodule
