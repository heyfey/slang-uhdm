// § genGateTermGenNetBind418
module m #(parameter N = 1) (input a, output y);
  if (N == 1) begin : g
    wire t;
    not n1 (t, a);
    buf b1 (y, t);
  end
endmodule
