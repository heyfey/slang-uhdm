// § strLitMacroRefSubst401
`define HI Hello
`define LO "`HI, world"
`define H(x) "Hello, x"
module top ();
initial begin
  $display("`HI, world");
  $display(`LO);
  $display(`H(world));
end
endmodule
