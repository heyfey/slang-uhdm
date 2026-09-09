// v226 b01 — HOLDER FENCE.  The identical body under every holder kind,
// uninstantiated and instantiated.  Only the uninstantiated INTERFACE column
// may move.
interface bif_uninst;
  logic a, b;
  int   q;
  initial begin
    q = 1;
    a = b;
  end
  always_comb b = a;
endinterface

interface bif_inst;
  logic a, b;
  int   q;
  initial begin
    q = 1;
    a = b;
  end
  always_comb b = a;
endinterface

module bmod_uninst;
  logic a, b;
  int   q;
  initial begin
    q = 1;
    a = b;
  end
  always_comb b = a;
endmodule

module bmod_inst;
  logic a, b;
  int   q;
  initial begin
    q = 1;
    a = b;
  end
  always_comb b = a;
endmodule

program bprog_uninst;
  logic a, b;
  int   q;
  initial begin
    q = 1;
    a = b;
  end
endprogram

checker bchk_uninst(logic a, logic b);
  default clocking @(posedge a); endclocking
  always_comb begin end
endchecker

module btop;
  bif_inst  ii();
  bmod_inst mi();
endmodule
