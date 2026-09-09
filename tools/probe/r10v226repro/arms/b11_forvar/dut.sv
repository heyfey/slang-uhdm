// v226 b11 — R-A.  The `for` header's own iterator, in an uninstantiated
// interface's FUNCTION, TASK, initial and always_comb, and in the same four
// under an INSTANTIATED interface and under a MODULE — the columns R-A's
// holder-flag gate must NOT move.
interface bf_uninst;
  int n = 4, acc;
  function automatic int f(); int s = 0;
    for (int k = 0; k < n; k++) s = s + k; return s; endfunction
  task automatic t(); acc = 0;
    for (int k = 0; k < n; k++) acc = acc + k; endtask
  initial begin
    for (int k = 0; k < n; k++) acc = acc + k;
  end
  always_comb begin
    for (int k = 0; k < n; k++) acc = acc + k;
  end
endinterface

interface bf_inst;
  int n = 4, acc;
  function automatic int f(); int s = 0;
    for (int k = 0; k < n; k++) s = s + k; return s; endfunction
  task automatic t(); acc = 0;
    for (int k = 0; k < n; k++) acc = acc + k; endtask
  initial begin
    for (int k = 0; k < n; k++) acc = acc + k;
  end
endinterface

module bf_mod;
  int n = 4, acc;
  function automatic int f(); int s = 0;
    for (int k = 0; k < n; k++) s = s + k; return s; endfunction
  initial begin
    for (int k = 0; k < n; k++) acc = acc + k;
  end
endmodule

module bf_top;
  bf_inst u();
endmodule
