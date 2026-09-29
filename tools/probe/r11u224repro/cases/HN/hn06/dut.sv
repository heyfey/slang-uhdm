// § hpLvNewClassFirstElemSpan224
class s; endclass
class r; s parent; endclass
module top;
  r rw;
  initial begin
    rw = new;
    rw.parent = new;
  end
endmodule
