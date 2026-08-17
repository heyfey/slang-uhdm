module orv #(
  parameter int WIDTH = 2,
  parameter int N     = 20
)(
  input   logic [N-1:0][WIDTH-1:0]  i_data,
  output  logic [WIDTH-1:0]         o_result
);
  function automatic int rec(int n);
    int acc;
    acc = 0;
    if (n > 0) begin
      acc += 1;
      acc = acc + rec(n-1);
    end
    return acc;
  endfunction
  localparam int R = rec(N);
  assign o_result = R[WIDTH-1:0];
endmodule
