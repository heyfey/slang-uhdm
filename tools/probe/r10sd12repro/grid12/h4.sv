// r10sd12 grid cell h4 — THE SITE AXIS, and the three NON-SUBROUTINE negatives
// this law must leave byte-identical.  The four production sites are a tf-item
// local, a `begin`-block local, a `fork` arm local and an `initial`-body local;
// a class PROPERTY, a PACKAGE variable and a MODULE variable are compiled by a
// different Surelog pass entirely and must not move.
package ph4;

  class zel4;
    int q;
  endclass

  class zo4;
    typedef zel4 d_t;
  endclass

  class auser4;
    zo4::d_t prop_q[$];        // CLASS PROPERTY   <- must NOT move
    zo4::d_t prop_fx[2];       // ditto, fixed     <- must NOT move

    function void f4();
      zo4::d_t tf_q[$];        // tf-item local
      zo4::d_t tf_fx[2];
      begin
        zo4::d_t blk_q[$];     // block-item local
        zo4::d_t blk_fx[2];
      end
      fork
        begin
          zo4::d_t fk_q[$];    // fork-arm local
        end
      join_none
    endfunction
  endclass

  zo4::d_t pkg_q[$];           // PACKAGE variable  <- must NOT move

endpackage

module toph4;
  import ph4::*;
  zo4::d_t mod_q[$];           // MODULE variable   <- must NOT move
  initial begin
    zo4::d_t ini_q[$];         // INITIAL-body local: compiled outside any class
    ph4::auser4 u = new();
    u.f4();
    ini_q = {};
  end
endmodule
