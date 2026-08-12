// r10svs9 arm b5 — the successor head, LOCALIZED.  b1/b2/b4 refuted program
// scope, instantiation, ports, `extends` and `constraint` as the discriminator.
// b3 showed one site converging and the other not; the ONE thing that separated
// them was that the losing site's handle is ASSIGNED BY `new()` in the
// program's initial block.  SVSwitch assigns BOTH of its sites that way
// (testcase.sv:26 `spkt = new();`, :27 `env = new(mem_intf,…)`), and BOTH lose
// the DEF-view `ref_typespec`.  This arm executes the split directly.
class K;
  int x;
  function new(int v = 0); x = v; endfunction
endclass

program tc;
  K r1;   // r1 NEVER assigned
  K r2;   // r2 assigned by `new()` with NO arguments
  K r3;   // r3 assigned by `new()` WITH an argument
  K r4;   // r4 assigned from ANOTHER HANDLE, not from new()
  initial begin
    r2 = new();
    r3 = new(7);
    r4 = r2;
  end
endprogram

module top; tc TC(); endmodule
