// t40a — the io_decl FORMAL DEFAULT matrix.  Scoreboard's census says golden
// KEEPS 152 ref_obj defaults and DROPS 89 rows of them; UVM_HIER appears on
// both sides.  The candidate discriminator read off the UVM sources is the
// explicit tf_port_direction keyword, NOT the enum kind:
//   dropped: `uvm_hier_e hier=UVM_HIER`      (uvm_reg_map::get_base_addr)
//   kept:    `input uvm_hier_e hier=UVM_HIER`(uvm_reg_block::get_blocks)
//   kept:    `int has_coverage=UVM_NO_COVERAGE` (uvm_reg_block::new, no dir)
// So the cells below cross { no dir | input | inherited-input | ref/output }
// x { named enum type | builtin int | typedef of int | class handle | string }
// x { first formal | later formal } x { in-body | extern out-of-body }.
package p40a;

  typedef enum int { E0, E1, E2 } e40_t;
  typedef int      i40_t;
  typedef struct packed { bit [3:0] a; } s40_t;
  parameter int P40 = 7;

  class h40;
    int z;
  endclass

  class c40;
    // --- IN-BODY, single formal, enum type -------------------------------
    function void f_nodir_enum   (      e40_t e = E1); endfunction
    function void f_input_enum   (input e40_t e = E1); endfunction
    // --- IN-BODY, single formal, builtin int ------------------------------
    function void f_nodir_int    (      int   k = 3);  endfunction
    function void f_input_int    (input int   k = 3);  endfunction
    // --- IN-BODY, single formal, typedef of int ---------------------------
    function void f_nodir_tdint  (      i40_t k = 3);  endfunction
    function void f_input_tdint  (input i40_t k = 3);  endfunction
    // --- IN-BODY, single formal, string / class handle / packed struct ----
    function void f_nodir_str    (      string s = "x");  endfunction
    function void f_input_str    (input string s = "x");  endfunction
    function void f_nodir_cls    (      h40 h = null);    endfunction
    function void f_input_cls    (input h40 h = null);    endfunction
    function void f_nodir_struct (      s40_t v = '{a:1});endfunction
    function void f_input_struct (input s40_t v = '{a:1});endfunction
    // --- IN-BODY, enum default spelled as a package parameter -------------
    function void f_nodir_param  (      int   k = P40); endfunction
    function void f_input_param  (input int   k = P40); endfunction
    // --- IN-BODY, LATER formal --------------------------------------------
    function void f_late_nodir   (string s,        e40_t e = E1); endfunction
    function void f_late_input   (input string s, input e40_t e = E1); endfunction
    // direction INHERITED from the previous explicit `input`
    function void f_late_inherit (input string s,       e40_t e = E1); endfunction
    // a `ref`-then-input pair, exactly uvm_reg_block::get_blocks' shape
    function void f_ref_input    (ref int q, input e40_t e = E1); endfunction
    // (`ref int q, e40_t e = E1` is ILLEGAL — the direction is inherited as
    //  `ref` and a ref formal may not carry a default.)
    // --- constructor -------------------------------------------------------
    function new(string name = "", int cov = E2); endfunction
    // --- EXTERN prototypes, definition out of body -------------------------
    extern function void g_nodir_enum (      e40_t e = E1);
    extern function void g_input_enum (input e40_t e = E1);
    extern function void g_nodir_int  (      int   k = 3);
    extern function void g_late_nodir (string s,       e40_t e = E1);
    extern function void g_late_input (input string s, input e40_t e = E1);
    // extern prototype WITH default, out-of-body WITHOUT it
    extern function void g_protoonly  (      e40_t e = E1);
    // (prototype WITHOUT default + out-of-body WITH one is ILLEGAL.)
    // --- TASK ---------------------------------------------------------------
    task t_nodir_enum (      e40_t e = E1); endtask
    task t_input_enum (input e40_t e = E1); endtask
  endclass

  function void c40::g_nodir_enum(      e40_t e = E1); endfunction
  function void c40::g_input_enum(input e40_t e = E1); endfunction
  function void c40::g_nodir_int (      int   k = 3);  endfunction
  function void c40::g_late_nodir(string s,       e40_t e = E1); endfunction
  function void c40::g_late_input(input string s, input e40_t e = E1); endfunction
  function void c40::g_protoonly (      e40_t e);      endfunction

  // --- PURE VIRTUAL prototypes: golden lists 107 io_decl rows on abstract
  //     UVM classes (uvm_factory, uvm_recorder, uvm_report_server, ...) that
  //     we do not list at all.  Both with and without defaults.
  virtual class a40;
    pure virtual function void pv_plain (int k);
    pure virtual function void pv_defint (int k = 3);
    pure virtual function void pv_defenum(      e40_t e = E1);
    pure virtual function void pv_definput(input e40_t e = E1);
    pure virtual task          pv_task   (int k, string s = "z");
    // a plain (non-pure) extern virtual for contrast
    extern virtual function void nv_extern(int k = 4);
  endclass

  function void a40::nv_extern(int k = 4); endfunction

  // an EXTERN-declared-but-never-defined prototype is illegal; skip.
endpackage

module top40a;
  import p40a::*;
  c40 c;
  initial c = new("n");
endmodule
