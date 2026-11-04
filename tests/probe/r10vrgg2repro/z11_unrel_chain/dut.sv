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
  localparam  bit [N-1:0][15:0] SUB_N_LIST  = get_sub_n_list(N);
  localparam int NX = N + 1;
  logic [NX:0] d;
  assign o_result = SUB_N_LIST[0][WIDTH-1:0];
endmodule
