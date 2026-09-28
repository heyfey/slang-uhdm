// § newArrayKeepFrozenBare201v
class C;
  int q[$];
  int n;
  byte data[];
  C h;
  task t();
    data = new[this.n + 1];
    data = new[h.n * 2](data);
    data = new[this.q.size];
  endtask
endclass
module top;
  C c;
  initial begin c = new; c.t(); end
endmodule
