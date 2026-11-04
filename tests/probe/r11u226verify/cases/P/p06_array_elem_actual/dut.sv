// § ppDotNameAfterArgToken219 — the actual is an array element and a plain handle, through two macros
`define GETN(O) O.get_name()
`define SHOW(O) \
  begin \
    $display("%s", `GETN(O)); \
  end
package p;
class e_c;
  function string get_name(); return "e"; endfunction
endclass
class user_c;
  e_c arr [3];
  e_c h;
  function void run();
    `SHOW(arr[1])
    `SHOW(h)
  endfunction
endclass
endpackage
module top;
  import p::*;
endmodule
