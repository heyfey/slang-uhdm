// v116 arm U -- macro-expanded randomize in both forms, and a randomize inside
// a nested class / constructor.  Macro surfaces are where rawText remaps.
`define RND_SCOPE(NM) if (!randomize(NM) with { NM > 0; }) mark_u = 1
`define RND_MEMB(OB) if (!OB.randomize()) mark_u = 2
class inner_u;
  rand int i_slot;
endclass
class outer_u;
  rand int o_slot;
  int mark_u;
  inner_u ih;
  function new();
    ih = new();
    if (!randomize(o_slot))
      mark_u = 7;
  endfunction
  function void run();
    `RND_SCOPE(o_slot);
    `RND_MEMB(ih);
  endfunction
endclass
module top_u;
  outer_u u_obj;
  initial begin
    u_obj = new();
    u_obj.run();
  end
endmodule
