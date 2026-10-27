// § nestProgAbstain444v
module top;
  logic a;
  program prg;
    int x;
    initial begin
      for (int k = 0; k < 2; k++) x = k;
    end
    function automatic int f(); logic [3:0] q [2]; q[0] = 1; return q[0]; endfunction
  endprogram
endmodule
