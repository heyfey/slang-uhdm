// r10uvm70 arm a1 — RETURN-TYPE grid, module-homed functions.
// The axis under test: an IMPLICIT base type carrying a WRITTEN signing
// keyword, in both directions, with and without a packed range, beside the
// fully-implicit and the EXPLICIT-base controls.
// LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours.
module a1;
  // --- IMPLICIT base, signing WRITTEN, NO range (the UVM head's shape) ---
  function unsigned f_bare_u;          // line 8
    f_bare_u = 1'b0;
  endfunction
  function signed f_bare_s;            // line 11
    f_bare_s = 1'b0;
  endfunction

  // --- IMPLICIT base, signing WRITTEN, WITH a packed range ---
  function unsigned [3:0] f_rng_u;     // line 16
    f_rng_u = 4'd0;
  endfunction
  function signed [3:0] f_rng_s;       // line 19
    f_rng_s = 4'd0;
  endfunction

  // --- IMPLICIT base, NO signing (controls) ---
  function f_implicit;                 // line 24  (nothing at all)
    f_implicit = 1'b0;
  endfunction
  function [3:0] f_rng_only;           // line 27  (range, no signing)
    f_rng_only = 4'd0;
  endfunction

  // --- EXPLICIT base + signing keyword (controls) ---
  function logic unsigned f_lg_u;      // line 32
    f_lg_u = 1'b0;
  endfunction
  function logic signed f_lg_s;        // line 35
    f_lg_s = 1'b0;
  endfunction
  function logic unsigned [3:0] f_lgr_u; // line 38
    f_lgr_u = 4'd0;
  endfunction
  function bit unsigned f_bit_u;       // line 41
    f_bit_u = 1'b0;
  endfunction
  function reg signed f_reg_s;         // line 44
    f_reg_s = 1'b0;
  endfunction

  // --- ATOM base + signing keyword (controls: the atom already wins) ---
  function int unsigned f_int_u;       // line 49
    f_int_u = 0;
  endfunction
  function int signed f_int_s;         // line 52
    f_int_s = 0;
  endfunction
  function byte unsigned f_byte_u;     // line 55
    f_byte_u = 0;
  endfunction

  // --- plain atom / plain logic (the untouched baseline) ---
  function int f_int;                  // line 60
    f_int = 0;
  endfunction
  function logic f_logic;              // line 63
    f_logic = 1'b0;
  endfunction
endmodule
