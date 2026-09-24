// r10oth8 arm a9 — the SCOPE NEGATIVE CONTROL, plus the witness standalone.
//
// The negative control matters because the law this pass ships is SCOPE-BOUND.
// A SUBROUTINE-LOCAL / STATEMENT-BLOCK-LOCAL dynamic array or queue puts
// signedness on the ELEMENT var, not on the array_var — that is what
// src/TaskFuncEmit.cpp already implements (`if (qelem0->isSigned())
// reg0->VpiSigned(true);`) and it is the OPPOSITE of the class/module rule.  If
// this pass's law were widened to those sites it would break them, so the cells
// below exist to be READ AND LEFT ALONE: `n01`..`n03` must show golden putting
// vpiSigned on the element and nothing on the array, and they must be
// IDENTICAL before and after the patch.
//
// `p01` is the WITNESS reduced to one file: SVSwitch Packet.sv:23's
// `rand byte data[];` inside a $unit class, which is the head at base 8d4d6ed.
class pc;
  rand byte p01_data[];
endclass

module a9_top;
  pc ph;
  function automatic int f();
    byte n01_loc_dyn[];      // SUBROUTINE LOCAL — element-signed, not array
    byte n02_loc_q[$];
    int  n03_loc_int[];
    n01_loc_dyn = new[1];
    n02_loc_q.push_back(0);
    n03_loc_int = new[1];
    return n01_loc_dyn.size() + n02_loc_q.size() + n03_loc_int.size();
  endfunction
  int r;
  initial begin
    byte n04_blk_dyn[];      // STATEMENT-BLOCK LOCAL
    ph = new();
    n04_blk_dyn = new[1];
    r = f() + n04_blk_dyn.size();
  end
endmodule
