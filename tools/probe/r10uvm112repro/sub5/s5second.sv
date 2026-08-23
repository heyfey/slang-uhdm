// a5 file 3 — declaring class `qq5` in ANOTHER package and ANOTHER FILE.
// Does the clone group span FILES and PACKAGES?  ASCII: "pk5u1::Nn5" <
// "pk5u2::qq5", so if it does, `qq5`'s Q must bind to `Nn5`.
package pk5u2;
  import pk5box::*;
  class qq5;
    typedef BoxW5 #(qq5,"qq5") wid5;
  endclass
endpackage
