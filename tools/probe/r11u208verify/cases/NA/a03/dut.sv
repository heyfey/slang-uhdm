// § newArrayKeepFrozenBare201v § newArrayPathStripTrailOnly201v § newArrayArgPathElemsStripped200
class P #(int W = 2);
  int n;
  byte d[];
  function void f();
    d = new[this.n];
    d = new[this.n * W](d);
  endfunction
endclass
class Outer;
  class Inner;
    int n;
    byte d[];
    task t();
      d = new[this.n - 1];
    endtask
  endclass
endclass
module a03;
  P #(3) p;
  Outer::Inner q;
  initial begin p = new; p.f(); q = new; q.t(); end
endmodule
