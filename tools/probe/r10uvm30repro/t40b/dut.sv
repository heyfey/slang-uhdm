// t40b — the CONTROL cells for t40a's decode.  t40a said: a formal written
// with NO tf_port_direction keyword whose data type is a NAMED user type
// (typedef enum / typedef int / typedef struct / class handle) loses its
// default value, while a BUILT-IN keyword type (int, string) keeps it.
// This arm asks the two questions that decides how wide the law is:
//   (a) which spellings count as "built-in" — bit/logic with dimensions,
//       real, time, byte, an INLINE anonymous enum/struct, a scoped
//       `pkg::t`, a parameterised class — and
//   (b) is it a CLASS-method rule or a subroutine rule: the same cells in a
//       PACKAGE function, a MODULE function, a module TASK and a $unit
//       function.
package q40b;
  typedef enum int { F0, F1 } f40_t;
  typedef int   j40_t;
  parameter int Q40 = 5;
  class g40; int z; endclass
endpackage

package p40b;
  import q40b::*;
  typedef enum int { E0, E1 } e40_t;

  class c40b;
    // built-in keyword types, NO direction keyword
    function void b_bit    (      bit [3:0] v = 4'h3); endfunction
    function void b_logic  (      logic     v = 1'b1); endfunction
    function void b_real   (      real      v = 1.5);  endfunction
    function void b_time   (      time      v = 3);    endfunction
    function void b_byte   (      byte      v = 8'h7); endfunction
    function void b_intu   (      int unsigned v = 3); endfunction
    function void b_lvec   (      logic [7:0] v = 8'h5);endfunction
    // INLINE anonymous enum / packed struct, NO direction keyword
    function void b_anonenum(     enum int { A0, A1 } v = A1); endfunction
    function void b_anonstr (     struct packed { bit [1:0] a; } v = 2'b10);
    endfunction
    // a SCOPED named type and a named type from a wildcard import
    function void b_scoped (      q40b::f40_t v = q40b::F1); endfunction
    function void b_imported(     f40_t v = F1); endfunction
    function void b_scopedcls(    q40b::g40 h = null); endfunction
    // the same cells WITH `input`
    function void i_bit    (input bit [3:0] v = 4'h3); endfunction
    function void i_anonenum(input enum int { B0, B1 } v = B1); endfunction
    function void i_scoped (input q40b::f40_t v = q40b::F1); endfunction
    // a named type default that is a LITERAL, not an enum name
    function void b_tdlit  (      j40_t k = 9); endfunction
    function void i_tdlit  (input j40_t k = 9); endfunction
    // a BUILT-IN type whose default names a package parameter (t40a saw
    // golden keep this as ref_obj 'P40' where we fold it to a constant)
    function void b_qparam (      int k = q40b::Q40); endfunction
  endclass

  // the same matrix on a PACKAGE-level function (no class in sight)
  function void pk_nodir_enum(      e40_t e = E1); endfunction
  function void pk_input_enum(input e40_t e = E1); endfunction
  function void pk_nodir_int (      int   k = 3);  endfunction
  function void pk_nodir_td  (      j40_t k = 3);  endfunction
endpackage

// $unit-scope function
function automatic void u_nodir_enum(p40b::e40_t e = p40b::E1); endfunction
function automatic void u_input_enum(input p40b::e40_t e = p40b::E1);
endfunction

module top40b;
  import p40b::*;
  import q40b::*;
  // MODULE-level function and task
  function automatic void md_nodir_enum(      e40_t e = E1); endfunction
  function automatic void md_input_enum(input e40_t e = E1); endfunction
  function automatic void md_nodir_int (      int   k = 3);  endfunction
  task automatic md_nodir_td (      j40_t k = 3); endtask
  task automatic md_input_td (input j40_t k = 3); endtask

  c40b c;
  initial begin
    c = new();
    md_nodir_enum();
    md_input_enum();
    md_nodir_int();
    md_nodir_td();
    md_input_td();
    u_nodir_enum();
    u_input_enum();
    pk_nodir_enum();
    pk_input_enum();
    pk_nodir_int();
    pk_nodir_td();
  end
endmodule
