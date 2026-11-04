// § hpLvNewClassFirstElemSpan224
class s; endclass
class r; s parent; endclass
program pr;
  r rw;
  initial begin rw = new; rw.parent = new; end
endprogram
module top; endmodule
