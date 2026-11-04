// § newArrayArgPathElemsStripped200 § newArrayPathStripTrailOnly201v § newArrayKeepFrozenBare201v
class Q; int q[$]; int n; endclass
class B; int bq[$]; int bn; endclass
class C extends B;
  Q h;
  int qq[$];
  byte data[];
  function int sz(); return 3; endfunction
  task t();
    data = new[this.h.q.size()];
    data = new[super.bq.size()];
    data = new[sz()];
    data = new[h.n + this.h.n];
    data = new[qq.size()];
    data = new[this.qq.size() + super.bn](data);
  endtask
endclass
module a01; C c; initial begin c = new; c.t(); end endmodule
