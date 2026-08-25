// r10v137 arm A — THE DRILLABLE-BASE MATRIX.
// r10uvm137's own arm B holds the dotted member name CONSTANT (`wells137`) and
// that member exists in ONE of the base types only, so every non-class base
// fails for a reason the base KIND did not cause.  Here the drilled member
// EXISTS in the base's own type for the struct bases too, which is the case
// `UHDM::ExprEval::hierarchicalSelector`'s `uhdmstruct_var` arm answers.
// MEASUREMENT ONLY.
package hallow137;

  typedef class Wraith137;

  typedef struct packed { bit [3:0] hi137; bit [3:0] lo137; } chip137_s;

  typedef struct { bit veins137[Wraith137];
                   int spans137[string];
                   bit hi137[Wraith137];
                   chip137_s tile137; } lode137_s;

  class Wraith137;
    bit veins137[Wraith137];
    int spans137[string];
    bit hi137[Wraith137];
    chip137_s tile137;
  endclass

  class Cavern137;
    extern function int delve137(ref lode137_s fld137[Wraith137],
                                 ref Wraith137 fcw137[Wraith137],
                                 ref bit       fbw137[Wraith137],
                                 ref lode137_s gld137[chip137_s],
                                 ref Wraith137 gcw137[chip137_s]);
  endclass

  function int Cavern137::delve137(ref lode137_s fld137[Wraith137],
                                   ref Wraith137 fcw137[Wraith137],
                                   ref bit       fbw137[Wraith137],
                                   ref lode137_s gld137[chip137_s],
                                   ref Wraith137 gcw137[chip137_s]);
    int tally137;
    // A1 — STRUCT base, the member EXISTS in the struct (Surelog drills it).
    foreach (fld137[s1]) foreach (s1.veins137[s2]) tally137++;
    // A2 — STRUCT base, a STRING-keyed member that exists in the struct.
    foreach (fld137[s3]) foreach (s3.spans137[s4]) tally137++;
    // A3 — CLASS base (control: resolves on both sides).
    foreach (fcw137[s5]) foreach (s5.veins137[s6]) tally137++;
    // A4 — BIT base (the corpus shape: must be the bare int_var).
    foreach (fbw137[s7]) foreach (s7.veins137[s8]) tally137++;
    // A5 — PACKED-STRUCT-KEYED outer, STRUCT element, member exists.
    foreach (gld137[s9]) foreach (s9.hi137[sa]) tally137++;
    // A6 — PACKED-STRUCT-KEYED outer, CLASS element, member exists.
    foreach (gcw137[sb]) foreach (sb.hi137[sc]) tally137++;
    // A7 — STRUCT base drilled TWO deep (through a packed member).
    foreach (fld137[sd]) foreach (sd.tile137.hi137[se]) tally137++;
    return tally137;
  endfunction

endpackage

module topa137;
  hallow137::lode137_s ald137[hallow137::Wraith137];
  hallow137::Wraith137 acw137[hallow137::Wraith137];
  bit                  abw137[hallow137::Wraith137];
  hallow137::lode137_s bld137[hallow137::chip137_s];
  hallow137::Wraith137 bcw137[hallow137::chip137_s];
  hallow137::Cavern137 cav137;
  int outa137;
  initial begin
    cav137 = new();
    outa137 = cav137.delve137(ald137, acw137, abw137, bld137, bcw137);
  end
endmodule
