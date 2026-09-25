// § classVarInitSpan152
class Outer;
  class Inner;
    int y;
  endclass
endclass
module top ();
  Outer::Inner i1 = new;
endmodule
