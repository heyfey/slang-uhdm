// r10uvm137 arm B — THE BASE-OBJECT KIND MATRIX.
// The dotted loop list is held CONSTANT (`<base>.wells137[k]`); what varies is
// the KIND Surelog gives the ENCLOSING foreach's loop variable that the dotted
// path is rooted at.  MEASUREMENT ONLY.
package forge137;

  typedef class Ingot137;
  typedef enum bit [2:0] { RAW137, HOT137, COLD137 } grade137_e;
  typedef struct packed { bit [3:0] hi137; bit [3:0] lo137; } plate137_s;

  class Ingot137;
    bit wells137[Ingot137];
    int spurs137[string];
  endclass

  // PACKAGE-LEVEL associative arrays keyed by a class, elements varied
  bit         pbit137[Ingot137];
  int         pint137[Ingot137];
  string      pstr137[Ingot137];
  Ingot137    pcls137[Ingot137];
  grade137_e  penu137[Ingot137];
  plate137_s  ppak137[Ingot137];
  real        prea137[Ingot137];

  class Smithy137;
    bit mbit137[Ingot137];          // CLASS PROPERTY assoc keyed by class
    extern function int temper137(ref bit  fbit137[Ingot137],
                                  ref int  fint137[Ingot137],
                                  ref string fstr137[Ingot137],
                                  ref Ingot137 fcls137[Ingot137],
                                  ref grade137_e fenu137[Ingot137],
                                  ref plate137_s fpak137[Ingot137],
                                  ref real frea137[Ingot137]);
  endclass

  function int Smithy137::temper137(ref bit  fbit137[Ingot137],
                                    ref int  fint137[Ingot137],
                                    ref string fstr137[Ingot137],
                                    ref Ingot137 fcls137[Ingot137],
                                    ref grade137_e fenu137[Ingot137],
                                    ref plate137_s fpak137[Ingot137],
                                    ref real frea137[Ingot137]);
    bit      lbit137[Ingot137];     // SUBROUTINE-LOCAL assoc keyed by class
    int      heat137;

    // B1..B7 — FORMAL outer array, element kind varied
    foreach (fbit137[z1]) foreach (z1.wells137[z2]) heat137++;
    foreach (fint137[z3]) foreach (z3.wells137[z4]) heat137++;
    foreach (fstr137[z5]) foreach (z5.wells137[z6]) heat137++;
    foreach (fcls137[z7]) foreach (z7.wells137[z8]) heat137++;
    foreach (fenu137[z9]) foreach (z9.wells137[za]) heat137++;
    foreach (fpak137[zb]) foreach (zb.wells137[zc]) heat137++;
    foreach (frea137[zd]) foreach (zd.wells137[ze]) heat137++;

    // B8..B14 — PACKAGE-LEVEL outer array, element kind varied
    foreach (pbit137[zf]) foreach (zf.wells137[zg]) heat137++;
    foreach (pint137[zh]) foreach (zh.wells137[zi]) heat137++;
    foreach (pstr137[zj]) foreach (zj.wells137[zk]) heat137++;
    foreach (pcls137[zl]) foreach (zl.wells137[zm]) heat137++;
    foreach (penu137[zn]) foreach (zn.wells137[zo]) heat137++;
    foreach (ppak137[zp]) foreach (zp.wells137[zq]) heat137++;
    foreach (prea137[zr]) foreach (zr.wells137[zs]) heat137++;

    // B15 — CLASS PROPERTY outer array (bit element)
    foreach (mbit137[zt]) foreach (zt.wells137[zu]) heat137++;
    // B16 — SUBROUTINE-LOCAL outer array (bit element)
    foreach (lbit137[zv]) foreach (zv.wells137[zw]) heat137++;
    // B17 — a NON-loop-var base under the SAME member, for contrast
    foreach (fbit137[zx]) heat137++;
    // B18 — THREE deep: the failing base, one more dot
    foreach (fbit137[zy]) foreach (zy.wells137[zz]) heat137++;
    // B19 — the failing base with a STRING-keyed member
    foreach (fbit137[y1]) foreach (y1.spurs137[y2]) heat137++;
    // B20 — the RESOLVING base with a STRING-keyed member
    foreach (fcls137[y3]) foreach (y3.spurs137[y4]) heat137++;
    // B21 — TWO named loop vars on the failing base's member
    foreach (fbit137[y5]) foreach (y5.wells137[y6]) heat137++;
    return heat137;
  endfunction

endpackage

module topf137;
  forge137::Smithy137 shop137;
  bit      abit137[forge137::Ingot137];
  int      aint137[forge137::Ingot137];
  string   astr137[forge137::Ingot137];
  forge137::Ingot137 acls137[forge137::Ingot137];
  forge137::grade137_e aenu137[forge137::Ingot137];
  forge137::plate137_s apak137[forge137::Ingot137];
  real     area137[forge137::Ingot137];
  int      out137;
  initial begin
    shop137 = new();
    out137 = shop137.temper137(abit137, aint137, astr137, acls137,
                               aenu137, apak137, area137);
  end
endmodule
