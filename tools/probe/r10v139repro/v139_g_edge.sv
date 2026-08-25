// r10v139 arm G — EDGE FACES: const / var modifiers, virtual and pure-virtual
// methods, a parameterised class with two specializations, a nested class, an
// extern-declared method whose body sits in another package scope, and a
// static class method holding a static local.
package Quiver139;
  virtual class Bowstring139 #(parameter int NOCK139 = 1);
    int limb139;
    virtual function void vFn139;
      int      aq;
      static int bq;
      automatic int cq;
      aq = NOCK139; bq = 2; cq = 3;
    endfunction
    pure virtual function void pFn139();
    static function void sFn139;
      int      dq;
      static int eq;
      automatic int fq;
      dq = 1; eq = 2; fq = 3;
    endfunction
    function void constVar139;
      const int gq = 3;
      var   int hq;
      int        iq;
      static int jq;
      hq = gq; iq = 1; jq = 2;
    endfunction
  endclass

  class Fletch139 #(parameter int NOCK139 = 2) extends Bowstring139 #(NOCK139);
    virtual function void pFn139();
      int      kq;
      static int lq;
      kq = 1; lq = 2;
    endfunction
    class Nockpoint139;
      function void nFn139;
        int      mq;
        static int nq;
        automatic int oq;
        mq = 1; nq = 2; oq = 3;
      endfunction
    endclass
  endclass

  // a function whose body block is ONE explicit begin/end
  function void oneBegin139;
    int      pq;
    static int qq;
    begin
      pq = 1; qq = 2;
    end
  endfunction

  // a function with a RETURN value and a paren-less header
  function int retNoParen139;
    int      rq;
    static int sq;
    string   tq = "t";
    rq = 1; sq = 2;
    return rq + sq + tq.len();
  endfunction
endpackage

module Bracer139;
  import Quiver139::*;
  Fletch139 #(3) f3139;
  Fletch139 #(4) f4139;
  initial begin
    f3139 = new();
    f4139 = new();
    f3139.vFn139();
    f4139.vFn139();
    void'(retNoParen139());
  end
endmodule
