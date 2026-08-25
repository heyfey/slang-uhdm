// r10v137 arm D — ARRAY KINDS x KEY TYPES x LOOP-VARIABLE COUNTS.
// The enclosing array is varied over associative (class / struct / string /
// int / enum / wildcard keys), queue, dynamic, fixed 1-D and fixed 2-D, in the
// admitted homes, and each dotted inner list is written only where the LRM
// makes the loop variable dottable.  MEASUREMENT ONLY.
package tally137;
  typedef class Bead137;
  typedef enum bit [1:0] { RED137, AMB137, GRN137 } hue137_e;
  typedef struct packed { bit [2:0] a137; bit [2:0] b137; } pip137_s;
  typedef struct { bit rows137[Bead137]; int cols137[string]; } abac137_s;
  class Bead137;
    bit rows137[Bead137];
    int cols137[string];
  endclass
  class Frame137;
    extern function int count137(
        ref abac137_s kcls137[Bead137],     // assoc, CLASS key,  struct elem
        ref Bead137   kcl2137[Bead137],     // assoc, CLASS key,  class  elem
        ref abac137_s kpst137[pip137_s],    // assoc, STRUCT key, struct elem
        ref bit       kstr137[string],      // assoc, STRING key
        ref bit       kint137[int],         // assoc, INT    key
        ref bit       khue137[hue137_e],    // assoc, ENUM   key
        ref bit       kwld137[*],           // assoc, WILDCARD key
        ref Bead137   kque137[$],           // QUEUE
        ref Bead137   kdyn137[],            // DYNAMIC
        ref Bead137   kfx1137[4],           // FIXED 1-D
        ref Bead137   kfx2137[3][2]);       // FIXED 2-D
  endclass

  function int Frame137::count137(
        ref abac137_s kcls137[Bead137],
        ref Bead137   kcl2137[Bead137],
        ref abac137_s kpst137[pip137_s],
        ref bit       kstr137[string],
        ref bit       kint137[int],
        ref bit       khue137[hue137_e],
        ref bit       kwld137[*],
        ref Bead137   kque137[$],
        ref Bead137   kdyn137[],
        ref Bead137   kfx1137[4],
        ref Bead137   kfx2137[3][2]);
    int n137;
    // D1/D2 — CLASS-keyed assoc, dotted inner (base is struct / class).
    foreach (kcls137[e1]) foreach (e1.rows137[e2]) n137++;
    foreach (kcl2137[e3]) foreach (e3.cols137[e4]) n137++;
    // D3 — STRUCT-keyed assoc, dotted inner off the packed-struct index.
    foreach (kpst137[e5]) foreach (e5.a137[e6]) n137++;
    // D4..D7 — the non-dottable keys: bare inner lists only.
    foreach (kstr137[e7]) n137++;
    foreach (kint137[e8]) n137++;
    foreach (khue137[e9]) n137++;
    if (kwld137.num() > 0) n137++;   // wildcard-indexed: foreach is illegal
    // D8..D11 — queue / dynamic / fixed 1-D / fixed 2-D: the loop variable is
    // an int index, so only bare inner lists are legal.
    foreach (kque137[eb]) n137++;
    foreach (kdyn137[ec]) n137++;
    foreach (kfx1137[ed]) n137++;
    foreach (kfx2137[ee, ef]) n137++;
    // D12 — a FIXED 2-D with a SKIPPED first dimension.
    foreach (kfx2137[, eg]) n137++;
    // D13 — a nested chain: class-keyed assoc, then the member's own assoc,
    // then that member's member (three loop variables deep).
    foreach (kcl2137[eh]) foreach (eh.rows137[ei]) foreach (ei.cols137[ej]) n137++;
    return n137;
  endfunction
endpackage

module topd137;
  tally137::Frame137 frm137;
  tally137::abac137_s acls137[tally137::Bead137];
  tally137::Bead137   acl2137[tally137::Bead137];
  tally137::abac137_s apst137[tally137::pip137_s];
  bit                 astr137[string];
  bit                 aint137[int];
  bit                 ahue137[tally137::hue137_e];
  bit                 awld137[*];
  tally137::Bead137   aque137[$];
  tally137::Bead137   adyn137[];
  tally137::Bead137   afx1137[4];
  tally137::Bead137   afx2137[3][2];
  int outd137;
  initial begin
    frm137 = new();
    outd137 = frm137.count137(acls137, acl2137, apst137, astr137, aint137,
                              ahue137, awld137, aque137, adyn137,
                              afx1137, afx2137);
  end
endmodule
