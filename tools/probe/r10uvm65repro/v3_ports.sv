// r10uvm65 VERIFIER arm v3_ports.sv - THE PORT-LIST PRODUCT, and the ONE port
// spelling neither b3 nor the law's wording covers: the NON-ANSI form.
//
// The law's task term is "a NON-EMPTY tf_port_list", read off
// `fd.prototype->portList->ports`.  b3 walks the ANSI spellings (`(int a)`,
// `(input int a)`, `()`, no parens).  It never writes:
//
//   r01  task t; input int a; endtask : t      <- NON-ANSI ports.  The formals
//        live in `items`, so `fd.items.empty()` is FALSE and sec 65 cannot fire -
//        yet Surelog DOES see a tf_port_list here.  If golden emits the block,
//        this is an UNDER-FIRE the stated law hides behind its own wording.
//   r02  the FUNCTION twin of r01.
//   r03  non-ANSI ports AND a statement (control: no block expected either way).
//
// Plus the ANSI port-shape product the law claims carries no term:
//   r04 default value · r05 `ref` · r06 `output` · r07 two ports · r08 unpacked
//   array port · r09 typedef'd port type · r10 `string` port · r11 a port whose
//   type is a CLASS handle · r12 `inout`.
// And the two remaining subroutine-kind cells:
//   r13 a pure-virtual TASK with a port (no body syntax -> must not fire)
//   r14 an extern prototype whose DEFINITION is in the class's package while the
//       prototype carries the ports (which syntax node the gate reads).

package v3p;
  typedef int v3_t;
  class v3c;
    // ---- r01/r02/r03: NON-ANSI port declarations
    task r01_t_nonansi;
      input int a;
    endtask : r01_t_nonansi                                  // r01
    function void r02_f_nonansi;
      input int a;
    endfunction : r02_f_nonansi                              // r02
    task r03_t_nonansi_body;
      input int a;
      $display("r03");
    endtask : r03_t_nonansi_body                             // r03

    // ---- r04..r12: the ANSI port-shape product
    task r04_t_default(int a = 1);
    endtask : r04_t_default                                  // r04
    task r05_t_ref(ref int a);
    endtask : r05_t_ref                                      // r05
    task r06_t_out(output int a);
    endtask : r06_t_out                                      // r06
    task r07_t_two(int a, string b);
    endtask : r07_t_two                                      // r07
    task r08_t_arr(int a[2]);
    endtask : r08_t_arr                                      // r08
    task r09_t_tdef(v3_t a);
    endtask : r09_t_tdef                                     // r09
    task r10_t_str(string a);
    endtask : r10_t_str                                      // r10
    task r11_t_cls(v3c a);
    endtask : r11_t_cls                                      // r11
    task r12_t_inout(inout int a);
    endtask : r12_t_inout                                    // r12

    // ---- r14: prototype carries the ports, definition is out of body
    extern task r14_t_oob(int a, string b);
  endclass

  task v3c::r14_t_oob(int a, string b);
  endtask : r14_t_oob                                        // r14

  // ---- r13: pure virtual task with a port
  virtual class v3vc;
    pure virtual task r13_t_pure(int a);
  endclass
endpackage

// ---- the module twins of the non-ANSI cells (a different Surelog entry point)
module v3m;
  task r15_t_nonansi;
    input int a;
  endtask : r15_t_nonansi                                    // r15
  function void r16_f_nonansi;
    input int a;
  endfunction : r16_f_nonansi                                // r16
  // control: ANSI port, module scope, fires
  task r17_t_ansi(int a);
  endtask : r17_t_ansi                                       // r17
endmodule
