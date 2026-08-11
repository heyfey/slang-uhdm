// r10uvm56 arm a8 — the SECOND law's witness, reduced out of
// uvm_mem_mam.svh:742: the return variable as the LHS of `= new(...)`, which
// § invalidNewCallFromSyntax55 re-parents through an ARTEFACT hier_path.  Both
// scopes, plus an ORDINARY LOCAL as the same lvalue (the positive control).
class item_c;
   int v;
   function new(int a);
      v = a;
   endfunction
endclass

class c8;
   // return variable as `= new()` lhs
   function item_c n_ret(int y);
      n_ret = new(y);
   endfunction
   // ordinary local as `= new()` lhs -- the control
   function item_c n_loc(int y);
      item_c loc;
      loc = new(y);
      n_loc = loc;
   endfunction
endclass

module a8_top;
   function item_c p_ret(int y);
      p_ret = new(y);
   endfunction
   function item_c p_loc(int y);
      item_c loc;
      loc = new(y);
      p_loc = loc;
   endfunction

   item_c r;
   c8 h;
   initial begin
      h = new();
      r = p_ret(1);
      r = p_loc(1);
      r = h.n_ret(1);
      r = h.n_loc(1);
   end
endmodule
