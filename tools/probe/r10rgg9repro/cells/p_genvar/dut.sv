module m #(
  parameter int N = 2
)();
  logic sig;
  logic [7:0] arr[4];
  genvar g;
  generate
    for (g = 0; g < 2; ++g) begin : gb
      assign arr[g] = (g) ? {2{sig}} : '0;
    end
  endgenerate
endmodule
module top;
  m u_a();
endmodule
