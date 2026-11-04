// § defGenUdpFormNoStmt307
program prg (input logic c, input logic d); initial $display(c, d); endprogram
module outer (input logic a, b);
  if (1) begin : g
    prg u_p (a, b);
  end
endmodule
module dut (input logic a, b);
  outer u1 (.a(a), .b(b));
endmodule
