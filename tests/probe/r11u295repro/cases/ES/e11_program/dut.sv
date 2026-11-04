// § escNameSpanSites295
program prg (input logic a);
  initial $display("%b", a);
endprogram
module dut (input logic a);
  prg \p.inst (.a(a));
endmodule
