// (r11u191 N0215 / N0229) references inside a package function formal's default value (uvm_globals.svh 144)
package p;
  typedef enum { E_A, E_B, E_C } sev_t;
  typedef enum { V_NONE = 0, V_LOW = 100, V_MED = 200 } verb_t;
  function void rep(sev_t severity, string id,
                    int verbosity = (severity == sev_t'(E_B)) ? V_LOW : (severity == sev_t'(E_C)) ? V_NONE : V_MED,
                    int line = 0);
  endfunction
endpackage
module top; endmodule
