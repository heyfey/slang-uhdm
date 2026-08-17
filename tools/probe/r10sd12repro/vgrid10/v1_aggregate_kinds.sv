// vsd10 adversarial cell v1 — AGGREGATE spellings of a LATE-SORTING owner's
// typedef, at subroutine-body scope.  The law's predicate keys on
// `dt->getType().kind == TypeAlias` and then mints a BARE class_var, which
// SKIPS the array-descent loop that models a tf-item array local by its
// ELEMENT.  If golden does not agree, the patch destroys the element object.
package px1;

  class kx1;
    int q;
  endclass

  class zhold1;
    typedef struct { int a; int b; } srec_t;
    typedef srec_t sq_t[$];
    typedef int    iq_t[$];
    typedef int    da_t[];
    typedef int    aa_t[string];
    typedef int    fa_t[4];
    typedef logic [3:0] pv_t;
    typedef pv_t   pa_t[2];
    typedef union packed { bit [31:0] a; bit [31:0] b; } sun_t;
    typedef enum { EA, EB } sen_t;
    typedef kx1    scls_t;
  endclass

  class auser1;
    function void f();
      zhold1::sq_t   a_q;
      zhold1::iq_t   a_iq;
      zhold1::da_t   a_da;
      zhold1::aa_t   a_aa;
      zhold1::fa_t   a_fa;
      zhold1::pa_t   a_pa;
      zhold1::sun_t  a_un;
      zhold1::sen_t  a_en;
      zhold1::scls_t a_cls;
      a_iq.push_back(1);
    endfunction

    // CONTROL: dims written on the DECLARATOR — the declared type is an array,
    // not a TypeAlias, so the law must not fire at all.
    function void g();
      zhold1::srec_t g_arr[4];
      zhold1::srec_t g_q[$];
      g_arr[0].a = 1;
    endfunction

    // the same aggregates as BLOCK-item locals (site 2)
    task t();
      begin
        zhold1::iq_t b_iq;
        zhold1::fa_t b_fa;
        b_iq.push_back(1);
        b_fa[0] = 2;
      end
    endtask
  endclass

endpackage

module top1;
  px1::auser1 u;
  initial u = new();
endmodule
