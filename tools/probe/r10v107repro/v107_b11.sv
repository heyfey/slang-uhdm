// r10v107 arm b11 — IS THE TYPEDEF/PARAMETER SUPPRESSOR PRE-EXISTING?
// The SAME name collision, but on the THREE name families that already reach
// the hoisted-net pool under the PRISTINE binary: § classPropRefs (a class
// PROPERTY), § classEnumConstBindsHoistNet76 (a class-scope ENUM CONSTANT) and
// a control that collides with nothing.  MEASUREMENT ONLY.
package pb11;
  typedef int   td_c11;             // collides with a class PROPERTY name
  typedef int   td_e11;             // collides with a class ENUM CONSTANT name
  parameter int pm_c11 = 4;         // collides with a second class PROPERTY

  class c11;
    int td_c11;                     // property whose name a package typedef spells
    int pm_c11;                     // property whose name a package parameter spells
    int uq_c11;                     // property nothing else spells (the control)
    typedef enum { td_e11, uq_e11 } e11_t;
    extern function int rd_prop();
    extern function int rd_enum();
  endclass

  function int c11::rd_prop();
    return td_c11 + pm_c11 + uq_c11;
  endfunction

  function int c11::rd_enum();
    return int'(td_e11) + int'(uq_e11);
  endfunction
endpackage

module topb11;
  import pb11::*;
  c11 inst;
  initial inst = new();
endmodule
