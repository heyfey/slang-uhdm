// r10uvm70 VERIFIER arm v5 — cells the implementer's grid does NOT contain.
// LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours.
package p5;
  class c5;
    // non-pure VIRTUAL class method, implicit+signing
    virtual function unsigned v_u;         // line 6
      v_u = 1'b0;
    endfunction
    // automatic lifetime spelled out
    function automatic unsigned au_u;      // line 10
      au_u = 1'b0;
    endfunction
    // (line 13 cell removed: slang rejects `function static` in a class —
    // SLANG_REJECT territory, out of campaign scope)
    function signed cls_s;                 // line 15
      cls_s = 1'b0;
    endfunction
  endclass
endpackage

interface if5;
  // interface-homed function, implicit+signing
  function unsigned if_u;                  // line 21
    if_u = 1'b0;
  endfunction
endinterface

module m5;
  // MULTI-DIM packed range on an implicit+signing return
  function unsigned [3:0][1:0] md_u;       // line 28
    md_u = 8'd0;
  endfunction
  // implicit+signing return on a function with ARGUMENTS (the UVM shape)
  function unsigned arg_u(input int a);    // line 32
    arg_u = 1'b0;
  endfunction
  // signing keyword written with a SIGNED range, the pre-existing arm's cell
  function signed [31:0] neg_s(input int a); // line 36
    neg_s = a;
  endfunction
  // inside a GENERATE block
  generate if (1) begin : g5
    function unsigned gen_u;               // line 41
      gen_u = 1'b0;
    endfunction
  end endgenerate
  // a function whose implicit+signing return is used by a self-reference
  function unsigned self_u;                // line 46
    self_u = self_u;
  endfunction
endmodule

program pr5;
  function unsigned pr_u;                  // line 52
    pr_u = 1'b0;
  endfunction
endprogram

// --- verifier's SECOND block: explicit-base controls the a1 grid omits ---
module m6;
  function logic signed [3:0] lgs_r;      // line 61
    lgs_r = 4'd0;
  endfunction
  function bit signed bs;                 // line 64
    bs = 1'b0;
  endfunction
  function reg unsigned ru;               // line 67
    ru = 1'b0;
  endfunction
  function byte signed bys;               // line 70
    bys = 0;
  endfunction
  function integer unsigned iu;           // line 73
    iu = 0;
  endfunction
endmodule
