// r10sd10 grid cell g2 — the SAME kinds as g1, but the OWNER class's FULL NAME
// now sorts AFTER the declaring class's full name (`px::auser` < `px::zholder`),
// which is the SeqDriver head's relation (`uvm_pkg::uvm_resource_base` <
// `uvm_pkg::uvm_resource_types`).  Surelog compiles class definitions in
// lexicographic order of their fully-qualified names, so `zholder`'s typedef
// typespecs do not exist yet when `auser`'s body is compiled.
package px;

  class kx;
    int q;
  endclass

  class zholder;
    typedef struct { int a; int b; } srec_t;
    typedef enum { EA, EB } senum_t;
    typedef int sint_t;
    typedef logic [3:0] svec_t;
    typedef bit [1:0] sbit_t;
    typedef string sstr_t;
    typedef kx scls_t;
    typedef real sreal_t;
    typedef time stime_t;
  endclass

  class auser;
    // class PROPERTY of a late-sorting owner's typedef (control: not a local)
    zholder::srec_t p_scoped_struct;

    function void f();
      zholder::srec_t  a_scoped_struct;   // THE HEAD SHAPE
      zholder::senum_t a_scoped_enum;
      zholder::sint_t  a_scoped_int;
      zholder::svec_t  a_scoped_vec;
      zholder::sbit_t  a_scoped_bit;
      zholder::sstr_t  a_scoped_str;
      zholder::scls_t  a_scoped_cls;
      zholder::sreal_t a_scoped_real;
      zholder::stime_t a_scoped_time;
      a_scoped_struct.a = 1;
      a_scoped_int = 1;
    endfunction

    // a task local, and a begin-block local, same shape
    task t();
      zholder::srec_t t_scoped_struct;
      begin
        zholder::srec_t b_scoped_struct;
        b_scoped_struct.a = 1;
      end
      t_scoped_struct.a = 1;
    endtask
  endclass

endpackage

module top;
  px::auser u;
  initial u = new();
endmodule
