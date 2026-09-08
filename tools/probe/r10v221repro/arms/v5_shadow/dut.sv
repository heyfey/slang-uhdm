// v5_shadow — CROSS-ENUM AND SHADOWED NAMES.  The declined mint is keyed on
// `&nv.symbol` (the resolved slang symbol), not on the NAME, so two different
// enums sharing a member name, and a local variable shadowing an enum member,
// must each be resolved independently.  A law that silenced "the name" would
// leak across the holders here.  The SAME member names appear in an
// uninstantiated interface (must go bare) and in an instantiated one and a
// module (must stay bound).
package v5pkg;
  typedef enum logic [1:0] { DUP = 2'd0, ONLY_P = 2'd1 } pa_e;
  typedef enum logic [1:0] { DUP2 = 2'd2, ONLY_Q = 2'd3 } pb_e;
endpackage

interface v5_uninst (input logic clk);
  import v5pkg::*;
  // a LOCAL enum re-using the imported member name DUP2
  typedef enum logic [2:0] { DUP2_L = 3'd5, LOCAL_ONLY = 3'd6 } loc_e;
  function automatic int f(input int k);
    int DUP = 7;                 // a LOCAL VARIABLE shadowing pkg member DUP
    int acc = DUP;               // resolves to the variable, not the enum
    acc += int'(ONLY_P);         // pkg enum A
    acc += int'(ONLY_Q);         // pkg enum B
    acc += int'(DUP2);           // pkg enum B member
    acc += int'(DUP2_L);         // local enum, name NEAR the pkg member
    acc += int'(LOCAL_ONLY);
    return acc;
  endfunction
endinterface

interface v5_inst (input logic clk);
  import v5pkg::*;
  typedef enum logic [2:0] { DUP2_L = 3'd5, LOCAL_ONLY = 3'd6 } loc_e;
  function automatic int f(input int k);
    int DUP = 7;
    int acc = DUP;
    acc += int'(ONLY_P);
    acc += int'(ONLY_Q);
    acc += int'(DUP2);
    acc += int'(DUP2_L);
    acc += int'(LOCAL_ONLY);
    return acc;
  endfunction
endinterface

module v5_mod (input logic clk);
  import v5pkg::*;
  typedef enum logic [2:0] { DUP2_L = 3'd5, LOCAL_ONLY = 3'd6 } loc_e;
  function automatic int f(input int k);
    int DUP = 7;
    int acc = DUP;
    acc += int'(ONLY_P);
    acc += int'(DUP2_L);
    return acc;
  endfunction
endmodule

module v5_top (input logic clk);
  v5_inst u_i (.clk(clk));
  v5_mod  u_m (.clk(clk));
endmodule
