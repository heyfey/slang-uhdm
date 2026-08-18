// r10uvm96 arm 4 — THE NEGATIVE ARM: a cast to a TYPEDEF NAME is NOT the
// keyword road.  Surelog's cast arm sees `slStringConst`, not a keyword node,
// and resolves the typedef's OWN typespec object; the keyword table must not
// reach these cells.  Each typedef aliases one of the keywords arm 1 moves, so
// a patch that keyed on the computed TYPE instead of the written keyword would
// light this arm up.
package g96_p4;
  typedef real      real_t;
  typedef shortreal sreal_t;
  typedef realtime  rtime_t;
  typedef time      time_t;
  typedef integer   integer_t;
  typedef longint   longint_t;
  typedef shortint  shortint_t;
  typedef int       int_t;
endpackage
module g96_a4;
  import g96_p4::*;
  int q;
  real out;
  initial begin
    out = real_t'(q);
    out = sreal_t'(q);
    out = rtime_t'(q);
    out = time_t'(q);
    out = integer_t'(q);
    out = longint_t'(q);
    out = shortint_t'(q);
    out = int_t'(q);
  end
endmodule
