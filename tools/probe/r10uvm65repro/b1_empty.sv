// r10uvm65 arm b1_empty.sv — EMPTY subroutine bodies, every shape that could
// carry the term.  The corpus witness is uvm_recorder::do_open:
//   protected virtual function void do_open(uvm_tr_stream stream,
//                                           time open_time,
//                                           string type_name);
//   endfunction : do_open
// golden gives it vpiStmt -> an EMPTY `begin` whose SPAN IS THE END LABEL
// TOKEN (547:18-547:25 = `do_open`) and whose only other field is
// vpiFullName = the subroutine's fullname.  We emit no vpiStmt at all.
//
// Cells vary, one axis at a time:
//   end label present / absent · function / task · void / non-void return ·
//   formals / none · virtual / plain / protected · class method / module twin /
//   package twin · explicit `begin end` / explicit `begin : lbl end` ·
//   constructor · one-statement control (must stay a bare statement).
class b1c;

  // ---- c01..c04: the corpus shape itself, end label PRESENT
  function void c01_f_lbl();
  endfunction : c01_f_lbl                                   // c01

  task c02_t_lbl();
  endtask : c02_t_lbl                                       // c02

  function int c03_f_ret_lbl();
  endfunction : c03_f_ret_lbl                               // c03

  protected virtual function void c04_f_virt_lbl(int a, string b);
  endfunction : c04_f_virt_lbl                              // c04

  // ---- c05..c08: the SAME four with NO end label
  function void c05_f_nolbl();
  endfunction                                               // c05

  task c06_t_nolbl();
  endtask                                                   // c06

  function int c07_f_ret_nolbl();
  endfunction                                               // c07

  protected virtual function void c08_f_virt_nolbl(int a, string b);
  endfunction                                               // c08

  // ---- c09/c10: an EXPLICIT empty block is not an absent body
  function void c09_f_beginend();
    begin
    end
  endfunction : c09_f_beginend                              // c09

  function void c10_f_namedbeginend();
    begin : c10_lbl
    end : c10_lbl
  endfunction : c10_f_namedbeginend                         // c10

  // ---- c11: ONE statement — golden must keep it BARE (no begin)
  function void c11_f_one();
    c01_f_lbl();
  endfunction : c11_f_one                                   // c11

  // ---- c12: TWO statements — the known second-item-anchored begin
  function void c12_f_two();
    c01_f_lbl();
    c01_f_lbl();
  endfunction : c12_f_two                                   // c12

  // ---- c13/c14: constructors
  function new();
  endfunction : new                                         // c13

  // ---- c15: empty body, formals on ONE line (span of end label unchanged?)
  function void c15_f_oneline(int a); endfunction : c15_f_oneline  // c15

  // ---- c16: static
  static function void c16_f_static();
  endfunction : c16_f_static                                // c16

  // ---- c17: a DECLARATION-ONLY body (locals, no statements)
  function void c17_f_declonly();
    int c17_v;
  endfunction : c17_f_declonly                              // c17

endclass

// ---- c18..c21: the MODULE twin of c01/c02/c05/c06
module b1m;
  function void c18_f_lbl();
  endfunction : c18_f_lbl                                   // c18
  task c19_t_lbl();
  endtask : c19_t_lbl                                       // c19
  function void c20_f_nolbl();
  endfunction                                               // c20
  function void c21_f_declonly();
    int c21_v;
  endfunction : c21_f_declonly                              // c21
endmodule

// ---- c22..c24: the PACKAGE twin
package b1p;
  function void c22_f_lbl();
  endfunction : c22_f_lbl                                   // c22
  task c23_t_lbl();
  endtask : c23_t_lbl                                       // c23
  class b1pc;
    virtual function void c24_f_lbl();
    endfunction : c24_f_lbl                                 // c24
  endclass
endpackage
