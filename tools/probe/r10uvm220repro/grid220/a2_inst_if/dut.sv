// r10uvm220 arm a2 — the SAME interface body, INSTANTIATED.
// `writeInstance` (UhdmWriter.cpp:4784-4786) runs `lateTypedefBinding` over the
// ModuleDefinition's late-binding list, so this is the arm that says whether an
// instance is what resolves the foreach header's placeholder.
class K220;
   int x;
endclass

interface if220i();

   int mvar220[4];
   parameter int PAR220[3] = '{1,2,3};

   function void f220(K220 a_dyn220[], input int a_fix220[4], input string a_q220[$]);
      int loc220[5];
      foreach (a_dyn220[i0]) begin       // s01 FORMAL, unsized dynamic of a class
      end
      foreach (a_fix220[i1]) begin       // s02 FORMAL, fixed-size int
      end
      foreach (a_q220[i2]) begin         // s03 FORMAL, queue of string
      end
      foreach (loc220[i3]) begin         // s04 SUBROUTINE LOCAL
      end
      foreach (mvar220[i4]) begin        // s05 INTERFACE MEMBER
      end
      foreach (PAR220[i5]) begin         // s06 PARAMETER
      end
   endfunction

   task t220(K220 b_dyn220[]);
      foreach (b_dyn220[j0]) begin       // s07 FORMAL of a TASK
      end
   endtask

endinterface

module top220i;
   if220i u220();
   initial begin
   end
endmodule
