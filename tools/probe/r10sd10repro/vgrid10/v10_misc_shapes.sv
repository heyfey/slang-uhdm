// vsd10 adversarial cell v10 — VIRTUAL/abstract owners, a TYPEDEF CHAIN through
// a second class, a CONSTRUCTOR local, a loop-body block local and a `const`
// local.  Every one of them reaches one of the three sites.
package pxa;

  virtual class zvirt10;
    typedef struct { int a; } v_t;
    pure virtual function void pv();
  endclass

  class zmid10;
    typedef struct { int m; } m_t;
  endclass

  class amid10;
    typedef zmid10::m_t chain_t;        // a CHAIN: alias of a class typedef
  endclass

  class auser10;
    function new();
      zvirt10::v_t n_ctor;              // a CONSTRUCTOR local
      n_ctor.a = 1;
    endfunction

    function void f();
      const zvirt10::v_t c_const = '{a:1};
      amid10::chain_t    c_chain;       // owner amid10 sorts BEFORE auser10
      zmid10::m_t        c_late;
      for (int k = 0; k < 2; k++) begin
        zvirt10::v_t l_loop;            // a LOOP-BODY block-item local
        l_loop.a = k;
      end
      c_chain.m = 2;
      c_late.m  = 3;
      if (c_const.a == 0) c_chain.m = 0;
    endfunction
  endclass

endpackage

module topa;
  pxa::auser10 u;
  initial u = new();
endmodule
