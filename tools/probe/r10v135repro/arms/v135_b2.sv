// r10v135 (VERIFIER) ARM b2 — DECLARATION HOMES.  ONE face (a plain class
// name) declared as an associative index in EVERY home the law could reach.
// Names are per-home so no home can be confirmed by another's answer.
package pkgHomeRomeo2;
  class keyOscarCls2;
    int kv;
  endclass

  // (H1) a package-scope VARIABLE
  bit h01PkgVar2 [keyOscarCls2];

  class carrierPapa2;
    // (H2) a class PROPERTY
    bit h02ClsProp2 [keyOscarCls2];
    // (H3) a STATIC class property
    static bit h03ClsStatic2 [keyOscarCls2];
    // (H4) an IN-BODY method local + (H5) its formal
    function void inbQuebec2(input bit h05InbFormal2 [keyOscarCls2]);
      bit h04InbLocal2 [keyOscarCls2];
      h04InbLocal2.delete();
    endfunction
    // (H6) an EXTERN prototype's formal
    extern function void oobSierra2(input bit h06ProtoFormal2 [keyOscarCls2]);
    extern task oobTaskTango2();
  endclass

  // (H7) the OUT-OF-BODY definition's own formal, (H8) its body local,
  // (H9) a NAMED begin-block local inside it, (H10) a fork block local
  function void carrierPapa2::oobSierra2(input bit h06ProtoFormal2 [keyOscarCls2]);
    bit h08OobLocal2 [keyOscarCls2];
    h08OobLocal2.delete();
    begin : blkUniform2
      bit h09BlkLocal2 [keyOscarCls2];
      h09BlkLocal2.delete();
    end
  endfunction

  task carrierPapa2::oobTaskTango2();
    bit h10OobTaskLocal2 [keyOscarCls2];
    h10OobTaskLocal2.delete();
  endtask

  // (H11) a FREE package function local + (H12) its formal
  function void freeVictor2(input bit h12FreeFormal2 [keyOscarCls2]);
    bit h11FreeLocal2 [keyOscarCls2];
    h11FreeLocal2.delete();
  endfunction

  // (H13) a free package TASK local
  task freeWhisky2();
    bit h13FreeTaskLocal2 [keyOscarCls2];
    h13FreeTaskLocal2.delete();
  endtask
endpackage

// (H14) a $unit-scope variable
import pkgHomeRomeo2::keyOscarCls2;
bit h14UnitVar2 [keyOscarCls2];

module topHomeXray2;
  import pkgHomeRomeo2::*;
  // (H15) a MODULE variable
  bit h15ModVar2 [keyOscarCls2];
  carrierPapa2 cYankeeHome2;
  // (H16) a MODULE's OWN function local  (R-MODFN)
  function void modZuluFn2();
    bit h16ModFnLocal2 [keyOscarCls2];
    h16ModFnLocal2.delete();
  endfunction
  initial begin
    cYankeeHome2 = new();
    cYankeeHome2.oobSierra2(h15ModVar2);
    cYankeeHome2.oobTaskTango2();
    cYankeeHome2.inbQuebec2(h15ModVar2);
    freeVictor2(h15ModVar2);
    freeWhisky2();
    modZuluFn2();
  end
endmodule
