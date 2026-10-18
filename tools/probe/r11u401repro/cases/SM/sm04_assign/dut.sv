// § strLitMacroRefSubst401
`define W 12345
module top ();
string s;
initial begin s = "w=`W;"; $display(s); end
endmodule
