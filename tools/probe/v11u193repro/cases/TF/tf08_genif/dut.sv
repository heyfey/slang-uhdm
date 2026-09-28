// § caTernFillArmKept193
module m #(parameter bit P = 1, parameter bit G = 1) ();
  logic s;
  logic [7:0] arr [2];
  if (G) begin : g
    assign arr[0] = (P) ? {8{s}} : '0;
  end
endmodule
module top;
  m #(.P(0)) u_a ();
  m #(.P(0)) u_b ();
endmodule
