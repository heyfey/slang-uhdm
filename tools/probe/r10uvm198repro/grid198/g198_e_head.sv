// r10uvm198 arm E — THE HEAD, minimised.  The corpus head is
// `uvm_component::m_set_cl_verb`'s `m_verbosity_setting setting;` — a local of
// the `begin` of a `foreach`, in an out-of-body method the importing package
// clones.  This file is the same shape in twenty lines and is the POSITIVE
// CONTROL for the whole pass: on the pristine binary its clone cells read the
// resolved struct, on the patched one the degraded placeholder golden reads.
package verbo198;
  class Comp198;
    typedef struct {
      string comp198;
      string phase198;
    } setting198;
    extern function void setCl198();
  endclass
  function void Comp198::setCl198();
    string values198[$];
    foreach (values198[i198]) begin
      setting198 setting198v;               // <- THE HEAD's shape
      setting198v.comp198 = values198[i198];
    end
  endfunction
endpackage
package adpcm198;
  import verbo198::*;
  class Env198;
    function void build198();
      Comp198 c198;
      c198 = null;
    endfunction
  endclass
endpackage
