// r10v202 arm 6 — TWO SEPARATE TYPEDEFS OF *ONE* SPECIALISATION (the brief's
// sharing control that grid arm A does not have: A holds two typedefs of two
// DIFFERENT specialisations).  Both name `GenV6202#(int)`, so Surelog mints ONE
// class_typespec for the group and spans both at the NAME-FIRST typedef, and
// § pkgImportClassTdClone50 models that.  The question this arm decides is
// whether the DEGRADE keeps the two names apart (golden's placeholder carries
// the WRITTEN name, one per declaration) once the resolved objects are shared.
// The HOME listings are scored beside the clone's.
package quarryV6202;
  class GenV6202 #(type TV6 = int);
    TV6 vV6;
  endclass

  typedef GenV6202#(int) tdAV6202;   // FIRST typedef of the specialisation
  typedef GenV6202#(int) tdBV6202;   // SECOND typedef of the SAME specialisation

  class AditV6202;
    extern function void winzeV6202();
  endclass

  function void AditV6202::winzeV6202();
    tdAV6202 tfAV6;
    tdBV6202 tfBV6;
    begin
      tdAV6202 blkAV6;
      tdBV6202 blkBV6;
      blkAV6 = null;
      blkBV6 = null;
    end
    tfAV6 = null;
    tfBV6 = null;
  endfunction
endpackage

package sluiceV6202;
  import quarryV6202::*;
  class FlumeV6202;
    function void raceV6202();
      AditV6202 gateV6;
      gateV6 = null;
    endfunction
  endclass
endpackage
