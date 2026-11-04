`ifndef BODY_SVH
`define BODY_SVH
  function automatic string f(int a); return $sformatf("%s %0d", `VS, a + 1); endfunction
`endif
