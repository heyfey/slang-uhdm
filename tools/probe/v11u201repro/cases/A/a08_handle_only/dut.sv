// § newArrayArgPathElemsStripped200
class C;
  int n;
  byte data[];
  C h;
  task t();
    data = new[h.n * 2];
  endtask
endclass
module top;
  C c;
  initial begin c = new; c.t(); end
endmodule
