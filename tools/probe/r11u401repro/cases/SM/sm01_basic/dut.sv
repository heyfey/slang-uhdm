// § strLitMacroRefSubst401
`define TWO_PLUS_TWO 5
module top ();
initial begin
  $display(":assert:(`TWO_PLUS_TWO == 5)");
  $display("x");
end
endmodule
