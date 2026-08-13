// r10uvm65 VERIFIER arm v4_items.sv - WHAT KIND OF `items` ENTRY BARS THE BLOCK?
//
// The shipped gate is `fd.items.empty()`, and the README defends it with three
// cells: a variable DECLARATION (c17/c21) and a NULL STATEMENT (d03) are
// golden-BARE.  v3_ports already refutes the general claim: NON-ANSI PORT
// declarations are `items` too, and golden emits the block anyway (r01/r02/
// r15/r16).  So `items.empty()` is a CONSERVATIVE SUBSET of golden's rule, and
// the question this arm settles is HOW conservative: which item kinds are
// invisible to Surelog's body walk (block emitted) and which are not.
//
// Every cell below is a labelled subroutine whose body holds exactly ONE item,
// varying the item KIND.  s10/s11 are the interaction with the TASK-SCOPE
// PARAMETER path (taskBodyPa9), which is built one statement BEFORE sec 65 and
// requires a NON-NULL body - so a task whose body is only a localparam is the
// one shape where sec 65's `if (!body)` and that wrapper can both decline.

package v4other;
  typedef int v4o_t;
endpackage

package v4p;
  class v4c;
    // ---- s01: body is only a wildcard IMPORT
    function void s01_f_import();
      import v4other::*;
    endfunction : s01_f_import                               // s01
    // ---- s02/s06 (a body-only TYPEDEF, plain and enum) CANNOT BE MEASURED:
    // Surelog SEGFAULTS on `function void f(); typedef int t; endfunction : f`
    // (rc=139, no database), so there is no golden to compare against.  Cells
    // removed and the crash recorded in README.verifier.md instead.
    // ---- s03: body is only TWO null statements
    function void s03_f_twonull();
      ;
      ;
    endfunction : s03_f_twonull                              // s03
    // ---- s04: body is only a STATIC variable declaration
    function void s04_f_static();
      static int s04_v;
    endfunction : s04_f_static                               // s04
    // ---- s05: body is only an EVENT declaration
    task s05_t_event(int a);
      event s05_e;
    endtask : s05_t_event                                    // s05
    // ---- s07: body is only a variable declaration WITH an initialiser
    function void s07_f_init();
      int s07_v = 3;
    endfunction : s07_f_init                                 // s07
    // ---- s08: body is only an empty `begin end` (control, golden keeps it)
    function void s08_f_beginend();
      begin
      end
    endfunction : s08_f_beginend                             // s08
    // ---- s09: CONTROL: nothing at all
    function void s09_f_empty();
    endfunction : s09_f_empty                                // s09
    // ---- s10/s11: the TASK-SCOPE PARAMETER path
    task s10_t_param(int a);
      localparam int P10 = 1;
    endtask : s10_t_param                                    // s10
    function void s11_f_param();
      localparam int P11 = 1;
    endfunction : s11_f_param                                // s11
  endclass
endpackage

module v4m;
  // the module twins of the two most load-bearing cells
  function void s12_f_import();
    import v4p::*;
  endfunction : s12_f_import                                 // s12
  task s13_t_param(int a);
    localparam int P13 = 1;
  endtask : s13_t_param                                      // s13
endmodule
