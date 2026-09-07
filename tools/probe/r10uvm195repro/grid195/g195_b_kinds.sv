// r10uvm195 arm B — the TYPE grid.  Every declared-type kind at the CLONE
// subroutine's own level, so the law's reach is measured against golden rather
// than assumed: only a `ref_var` carries `vpiActual` at all.
package anvil195;
  typedef struct packed { logic [3:0] a; } hammer_t195;
  typedef logic [7:0] rivet_t195;
  class Bellows195;
  endclass
  function void kinds195();
    process        k_proc195;
    semaphore      k_sem195;
    mailbox        k_mbx195;
    event          k_evt195;
    Bellows195     k_cls195;
    string         k_str195;
    int            k_int195;
    bit            k_bit195;
    logic [3:0]    k_log195;
    real           k_real195;
    hammer_t195    k_struct195;
    rivet_t195     k_td195;
    chandle        k_ch195;
    std::process   k_scoped195;
    int            k_q195[$];
    int            k_dyn195[];
    int            k_asc195[string];
    int            k_fix195[4];
    k_int195 = 0;
  endfunction
  task kindsTask195(int inArg195 = 0);
    process        t_proc195;
    string         t_str195;
    t_str195 = "z";
  endtask
endpackage
package crucible195;
  import anvil195::*;
  class Ladle195;
    function void stile195();
      Bellows195 l_h195;
      l_h195 = null;
    endfunction
  endclass
endpackage
