// r10uvm220 arm a1 — an UNINSTANTIATED interface's foreach headers.
// Nothing instantiates `if220u`, so Surelog never elaborates it and
// `UhdmWriter::writeInterface` (UhdmWriter.cpp:1626-1794) runs neither
// `lateTypedefBinding` nor `lateBinding` over it.  MiniAmiq's
// `svaunit_vpi_interface` is exactly this shape.
class K220;
   int x;
endclass

interface if220u();

   int mvar220[4];                       // s05: an INTERFACE MEMBER array
   parameter int PAR220[3] = '{1,2,3};   // s06: a PARAMETER array

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

   initial begin
      foreach (mvar220[k0]) begin        // s18 OUTSIDE any subroutine
      end
   end

endinterface

module top220u;
   initial begin
   end
endmodule
