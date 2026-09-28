// § newArrayKeepFrozenBare201v
class C;
  int n;
  byte data[];
  task t();
    data = new[this.n + 1];
  endtask
endclass
module top;
  C c;
  initial begin c = new; c.t(); end
endmodule
