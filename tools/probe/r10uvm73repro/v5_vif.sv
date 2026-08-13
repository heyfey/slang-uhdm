// r10uvm73 VERIFIER arm v5 — the § 73 x § virtualIfacePropIsBareLogicVar6
// INTERACTION.  foreignTd73 sets `v` BEFORE the vif arm's `if (!v && ...)`, so
// a CLASS-SCOPE-QUALIFIED virtual-interface typedef now takes the §73 path and
// leaves vifProp6 FALSE where it used to be TRUE.  Both of vifProp6's readers
// are OR'd with foreignTd73, so this should be inert -- MEASURED, not assumed.
interface w_if; logic a; modport IP (input a); endinterface
package p1;
  class vholder;
    typedef virtual w_if      vi_t;
    typedef virtual w_if.IP   vim_t;
  endclass
  class vuser;
    vholder::vi_t   c_qual_vif;      // class-qualified VIF typedef  (both laws)
    vholder::vim_t  c_qual_vifmp;    // ...with a modport
    typedef virtual w_if own_vi_t;
    own_vi_t        k_own_vif;       // own typedef, bare -> vifProp6 ONLY
    virtual w_if    k_plain_vif;     // written plain     -> vifProp6 ONLY
    vholder::vi_t   c_qual_vif_null = null;   // + the null-init half
    own_vi_t        k_own_vif_null  = null;
  endclass
endpackage
module top; p1::vuser u; initial u = new(); endmodule
