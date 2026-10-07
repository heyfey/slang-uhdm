// § fnRetLitRhsSharesDefConst273
module m #(parameter int P = 0) (output int o);
  function automatic int f();
    if (P == 0) return 1;
    else return 2;
  endfunction
  assign o = f();
endmodule
module dut (output int a, output int b);
  m #(.P(0)) u0(.o(a));
  m #(.P(1)) u1(.o(b));
endmodule
