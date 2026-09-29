// § strLitPpEscIdShift224
module top #(parameter bit G = 1) (output string o);
  if (G) begin : g1
    string s = "a\nb` c"; assign o = s;
  end
endmodule
