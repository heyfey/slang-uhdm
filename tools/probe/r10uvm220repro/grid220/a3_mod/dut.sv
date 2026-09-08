// r10uvm220 arm a3 — the SAME body in a MODULE (the calibration arm).
// `writeModule` (UhdmWriter.cpp:1402-1625) runs `lateBinding` but NOT
// `lateTypedefBinding`; `writeInstance` runs both.  A module with no
// instantiator is a TOP, hence always elaborated, so `m220sub` is instantiated
// by `top220m` and `m220top` is a top in its own right.
class K220;
   int x;
endclass

module m220sub;

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
      foreach (mvar220[i4]) begin        // s05 MODULE MEMBER
      end
      foreach (PAR220[i5]) begin         // s06 PARAMETER
      end
   endfunction

endmodule

module top220m;
   m220sub u220();
   initial begin
   end
endmodule
