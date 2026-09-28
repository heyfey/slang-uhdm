// § newArrayArgPathElemsStripped200
class B; int bn; endclass
class C extends B;
  int n;
  C h;
  byte data[];
  task t();
    data = new[super.bn + 1];
    data = new[this.h.n];
    data = new[h.h.n - 1];
  endtask
endclass
module top;
  C c;
  initial begin c = new; c.t(); end
endmodule
