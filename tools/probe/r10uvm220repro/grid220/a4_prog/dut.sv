// r10uvm220 arm a4 — the SAME body in a PROGRAM, uninstantiated and
// instantiated.  `writeProgram` (UhdmWriter.cpp:1795-1900) has neither late
// pass; `writeElabProgram` (:2071-2072) has both.  This arm says whether the
// law's holder is "an interface" or "anything Surelog never elaborates".
class K220;
   int x;
endclass

program pr220u();
   function void f220(K220 a_dyn220[], input int a_fix220[4]);
      int loc220[5];
      foreach (a_dyn220[i0]) begin       // s01 FORMAL, unsized dynamic of a class
      end
      foreach (a_fix220[i1]) begin       // s02 FORMAL, fixed-size int
      end
      foreach (loc220[i3]) begin         // s04 SUBROUTINE LOCAL
      end
   endfunction
endprogram

program pr220i();
   function void g220(K220 a_dyn220[], input int a_fix220[4]);
      int loc220[5];
      foreach (a_dyn220[i0]) begin       // s01 FORMAL, unsized dynamic of a class
      end
      foreach (a_fix220[i1]) begin       // s02 FORMAL, fixed-size int
      end
      foreach (loc220[i3]) begin         // s04 SUBROUTINE LOCAL
      end
   endfunction
endprogram

module top220p;
   pr220i u220();
   initial begin
   end
endmodule
