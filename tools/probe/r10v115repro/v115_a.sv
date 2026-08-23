// v115_a — SHAPES THE IMPLEMENTER'S GRID DOES NOT COVER (declaration sites).
typedef process ta_pt;            // $unit typedef of the builtin
function automatic int ua_fn;     // a $unit FREE function
  process ua_p;                   // $unit function body local
  semaphore ua_s;
  return 1;
endfunction

package pa_pkg;
  typedef process lo_pt;            // package-local typedef of the builtin
  class ca_cls;
    static function void sm_fn();     // a STATIC class method, IN body
      process sm_p;
      mailbox sm_m;
    endfunction
    extern static function void sm_oob2();
    function void nb_fn();
      begin : nb_named                // a NAMED block inside an in-body method
        process nb_p;
      end
    endfunction
  endclass
  function void ca_cls::sm_oob2();    // OUT-OF-BODY STATIC method
    process so_p;
    mailbox #(int) so_mi;             // PARAMETERISED mailbox
  endfunction
  function automatic void pa_fn();
    mailbox #(int) pf_mi;             // parameterised, package free function
    lo_pt pf_td;                      // a TYPEDEF of the builtin (package-local)
    begin : pf_named
      process pf_np;                  // NAMED block inside a package function
    end
  endfunction
endpackage

program pr_prog;
  initial begin
    process pr_p;                     // PROGRAM initial local
    pr_p = process::self();
  end
  task automatic pr_tk();
    process pr_tp;                    // PROGRAM task local
  endtask
endprogram

interface if_iface;
  initial begin
    process if_p;                     // INTERFACE initial local
  end
  function automatic int if_fn();
    process if_fp;                    // INTERFACE function local
    return 0;
  endfunction
endinterface

module ma_top;
  always @(*) begin
    process al_p;                     // ALWAYS body local
    al_p = process::self();
  end
  always_comb begin
    process ac_p;
    ac_p = process::self();
  end
  initial begin : in_named            // a NAMED initial block
    process nn_p;
    nn_p = process::self();
  end
  if_iface u_if();
endmodule
