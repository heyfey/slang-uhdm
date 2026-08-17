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
endpackage
module orv #(
  parameter int WIDTH = 2,
  parameter int N     = 20
)(
  input   logic [N-1:0][WIDTH-1:0]  i_data,
  output  logic [WIDTH-1:0]         o_result
);
  localparam bit [24:0][15:0] SUB_N_LIST = p::get_sub_n_list(25);
  assign o_result = SUB_N_LIST[0][WIDTH-1:0];
endmodule
