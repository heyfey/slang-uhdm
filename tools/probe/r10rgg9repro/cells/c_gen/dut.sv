module m #(
  parameter bit P = 0
)();
  logic sig;
  logic [7:0] arr[2];
  generate
    if (1) begin : gb
      assign arr[0] = (P) ? {2{sig}} : '0;
    end
  endgenerate
endmodule
module top;
  m #(.P(0)) u_a();
endmodule
