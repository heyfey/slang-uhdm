module leaf #(
  parameter bit P = 0
)();
  logic sig;
  logic [7:0] arr[2];
  assign arr[0] = (P) ? {2{sig}} : '0;
endmodule
module mid #(
  parameter bit P = 0
)();
  leaf #(.P(P)) u_l();
endmodule
module top;
  mid #(.P(0)) u_a();
  mid #(.P(1)) u_b();
endmodule
