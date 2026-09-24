// r10v195 arm D — the § tfItemLocalAutomaticIsNotWrittenStatic139 faces: the
// TF-ITEM production (no body `begin`, so the ONE object is unbound IN PLACE
// rather than twinned), with `automatic` / `static` lifetimes, a body io
// declaration, and a named/nested begin at function level.  MEASUREMENT ONLY.
package moor195v;
  function automatic void gorse195v;
    process go_p195v;
    string  go_s195v;
    go_s195v = "p";
  endfunction
  function static void heath195v;
    process he_p195v;
    string  he_s195v;
    he_s195v = "q";
  endfunction
  task automatic bracken195v;
    input int br_in195v;
    process br_p195v;
    string  br_s195v;
    br_s195v = "r";
  endtask
  function void furze195v();
    process fu_p195v;
    fz195v: begin
      process fu_n195v;
      string  fu_s195v;
      fu_s195v = "s";
    end
  endfunction
  function void ling195v();
    process li_p195v;
    begin
      begin
        process li_n195v;
        string li_s195v;
        li_s195v = "t";
      end
    end
  endfunction
  function void sedge195v;
    process se_p195v;
  endfunction
endpackage
package fen195v;
  import moor195v::*;
  class Curlew195v;
    function void call195v();
      int c_i195v;
      c_i195v = 0;
    endfunction
  endclass
endpackage
