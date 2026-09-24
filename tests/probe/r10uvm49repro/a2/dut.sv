// a2 — CONTAINER = PACKAGE ONLY.  No module imports p49b, so the only container
// is the package itself.  This is the cell that makes the ref_typespec fullname
// LOOK doubled: container prefix `p49b::` + package-qualified name
// `p49b::zzz_first_t` = `p49b::p49b::zzz_first_t`.
// Read against a1 (container = MODULE) to decide rule (4).
package p49b;

  class gc49 #(type KEY = int, type T = int);
    int k;
  endclass

  typedef gc49#(string, int) zzz_first_t;
  typedef gc49#(string, int) aaa_second_t;

  class holder49;
    zzz_first_t hz;
    aaa_second_t ha;
  endclass

endpackage

module a2_top;
  int unused;
endmodule
