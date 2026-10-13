// § nestedDefSecondBodyReadsRep307
module outer (input logic a);
  program pinner (input logic i);
    initial $display("%b", i);
  endprogram
  pinner u_p (.i(a));
endmodule
module dut (input logic [1:0] a);
  outer u_o (.a(a[0]));
  outer u_q (.a(a[1]));
endmodule
