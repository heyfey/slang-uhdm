// § labeledCallStmtLabelDropped415
module sub;
  function int f(input int x); return x + 1; endfunction
endmodule
module top(output int o);
  sub u();
  initial begin
    lf: void'(u.f(5));
    o = 1;
  end
endmodule
