module orv #(
  parameter int WIDTH = 2,
  parameter int N     = 20
)(
  input   logic [N-1:0][WIDTH-1:0]  i_data,
  output  logic [WIDTH-1:0]         o_result
);
  function automatic bit [N-1:0][15:0] f(int n);
    bit [N-1:0][15:0] list;
    int i;
    list = '0;
    i = 0;
    while (i < n) begin
      list[i] = 16'(i);
      i += 1;
    end
    return list;
  endfunction
  localparam  bit [N-1:0][15:0] SUB_N_LIST  = f(N);
  assign o_result = SUB_N_LIST[0][WIDTH-1:0];
endmodule
