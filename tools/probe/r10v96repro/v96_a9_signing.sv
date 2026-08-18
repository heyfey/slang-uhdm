// r10v96 arm 9 — SIGNING variants on the moving keywords (compileBuiltinTypespec
// opens isSigned=true and only an explicit `unsigned` clears it).
package v96p9;
  function automatic void f9();
    logic [31:0] v;
    longint      i;
    i = integer'(v);
    i = integer unsigned'(v);
    i = integer signed'(v);
    i = longint unsigned'(v);
    i = shortint unsigned'(v);
    i = int unsigned'(v);
    i = byte unsigned'(v);
    i = time'(v);
    $display("%0d", i);
  endfunction
endpackage
