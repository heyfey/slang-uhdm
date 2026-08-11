// a5 — TWO CONTAINERS import the SAME specialisation.  Is the class_typespec
// minted ONCE and shared, or ONCE PER CONTAINER?  If per-container, each copy's
// ref_typespec fullname should carry ITS OWN container prefix, which is the
// second half of rule (4).
package p49e;

  class gc49 #(type KEY = int, type T = int);
    int k;
  endclass

  typedef gc49#(string, int) zzz_first_t;
  typedef gc49#(string, int) aaa_second_t;

endpackage

module a5_mod_one;
  import p49e::*;
  zzz_first_t m1;
endmodule

module a5_mod_two;
  import p49e::*;
  zzz_first_t m2;
endmodule

module a5_top;
  a5_mod_one u1();
  a5_mod_two u2();
endmodule
