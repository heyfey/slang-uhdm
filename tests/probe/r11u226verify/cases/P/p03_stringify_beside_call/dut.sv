// § ppDotNameAfterArgToken219 § ppIdentEndInRebuiltText219 — a stringified formal beside a method call on the same actual, through two macros
`define MSG(OBJ,TAG) $display(`"TAG: %s`", OBJ.get_full_name())
`define WRAP(OBJ,TAG) \
  begin \
    `MSG(OBJ,TAG); \
  end
package p;
class node_c;
  function string get_full_name(); return "n"; endfunction
endclass
class user_c;
  node_c nd;
  function void run();
    `WRAP(nd, CHECK)
  endfunction
endclass
endpackage
module top;
  import p::*;
endmodule
