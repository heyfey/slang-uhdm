// § newArrayKeepFrozenBare201v § newArrayArgPathElemsStripped200 § newArrayPathStripTrailOnly201v
package pk;
  class Cfg; int n; endclass
  class B; int bn; endclass
  class C extends B;
    typedef Cfg cfg_t;
    cfg_t cfg;
    int q[$];
    int d[];
    function void g();
      d = new[this.cfg.n];
      d = new[this.q.size()];
      d = new[super.bn + this.cfg.n](d);
      d = new[this.bn];
    endfunction
  endclass
endpackage
module a04; pk::C c; initial begin c = new; c.g(); end endmodule
