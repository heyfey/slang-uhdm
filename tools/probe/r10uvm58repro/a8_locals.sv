// r10uvm58 arm a8 — WHERE ELSE A TYPE-PARAMETER-TYPED DECLARATION LIVES:
// a subroutine LOCAL, a begin-block LOCAL, a for-loop variable, and the
// CLASS PROPERTY (which Surelog compiles through ElaborationStep's Parameter
// branch, not compileVariable, and must therefore stay a CONCRETE var).
package p58a8;
   class c_loc #(type T=int);
      T m_prop;                         // class PROPERTY (control)
      function bit m1();
         T lv;                          // subroutine LOCAL
         lv = m_prop;
         return 1;
      endfunction
      function bit m2();
         begin : blk
            T bv;                       // begin-block LOCAL
            bv = m_prop;
         end
         return 1;
      endfunction
      function bit m3();
         for (int i = 0; i < 2; i++) begin
            T fv;                       // loop-body LOCAL
            fv = m_prop;
         end
         return 1;
      endfunction
   endclass
endpackage

module a8_top58;
   initial begin end
endmodule
