// vsd12 cell v6 — INTERFACE CLASSES.  vsd11 found an interface-class edge that
// r10sd11's grid did not contain; this law's OWNER term asks only
// `kind == ClassType`, and slang models an `interface class` as a ClassType
// too, so an interface class's typedef reaches this law exactly like a normal
// class's.  Whether SURELOG's `paClass_scope` treats it the same is NOT
// derivable and has to be measured.
//
// Both order directions, plus an IMPLEMENTING class naming the interface
// class's typedef bare through inheritance.
package pv6;

  interface class aic6;
    typedef int a_t;
  endclass

  interface class zic6;
    typedef int z_t;
  endclass

  class muser6;
    function void f6();
      aic6::a_t a_q[$];       // EARLY-sorting interface-class owner
      aic6::a_t a_s;
      zic6::z_t z_q[$];       // LATE-sorting interface-class owner
      zic6::z_t z_s;
      a_q = {};
      z_q = {};
    endfunction
  endclass

endpackage

module topv6;
  initial begin
    $display("v6");
  end
endmodule
