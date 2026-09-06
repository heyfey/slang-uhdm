// r10uvm176 arm D — THE ARGUMENT KINDS and the CONTROL-BODY DEPTHS.  One
// receiver spelling (a plain vif property), one call, and every kind of thing
// that can be written as its argument, at every depth the family's gate reads.
// MEASUREMENT ONLY.
package store176;
   int shelf176 = 7;
endpackage

interface sink_if176;
   int  seen176;
   function automatic void take176(int one176, int two176);
      seen176 = one176 + two176;
   endfunction
   function automatic void one176(int solo176);
      seen176 = solo176;
   endfunction
endinterface

class feeder176;
   virtual sink_if176 pipe176;
   int                owned176;        // a class PROPERTY
   static int         shared176 = 5;   // a STATIC class property
   parameter int      FIXED176 = 9;    // a class PARAMETER

   // ---- D1: FORMAL + BODY LOCAL, depth 0
   function void d1_depth0(int kilo176);
      int lark176;
      lark176 = 1;
      pipe176.take176(kilo176, lark176);          // a_formal0 / a_local0
   endfunction

   // ---- D2: the same names one CONTROL BODY down
   function void d2_depth1(int mike176);
      int moss176;
      moss176 = 1;
      if (owned176 > 0) begin
         pipe176.take176(mike176, moss176);       // a_formal1 / a_local1
      end
   endfunction

   // ---- D3: a BLOCK LOCAL declared in the very block that raises the depth
   function void d3_blocklocal(int nova176);
      if (owned176 > 0) begin
         int nook176;
         nook176 = 2;
         pipe176.take176(nova176, nook176);       // a_formal1b / a_blk1
      end
   endfunction

   // ---- D4: an UNNAMED begin at depth 0 (raises no depth)
   function void d4_bareblock(int oscar176);
      begin
         int oath176;
         oath176 = 3;
         pipe176.take176(oscar176, oath176);      // a_formal0b / a_blk0
      end
   endfunction

   // ---- D5: a NAMED block
   function void d5_namedblock(int papa176);
      begin : perch176
         int posy176;
         posy176 = 4;
         pipe176.take176(papa176, posy176);       // a_formal_nb / a_blk_nb
      end
   endfunction

   // ---- D6: TWO control bodies down
   function void d6_depth2(int quilt176);
      if (owned176 > 0) begin
         for (int q2 = 0; q2 < 2; q2++) begin
            pipe176.take176(quilt176, q2);        // a_formal2 / a_loopvar2
         end
      end
   endfunction

   // ---- D7: a class PROPERTY, a STATIC property and a class PARAMETER
   function void d7_props();
      pipe176.take176(owned176, shared176);       // a_prop / a_static
   endfunction
   function void d7b_param();
      pipe176.one176(FIXED176);                   // a_param
   endfunction

   // ---- D8: a PACKAGE variable
   function void d8_pkgvar();
      pipe176.one176(store176::shelf176);         // a_pkgvar
   endfunction

   // ---- D9: a LITERAL and an EXPRESSION over a formal
   function void d9_shapes(int romeo176);
      pipe176.take176(42, romeo176 + 1);          // a_lit / a_oper
   endfunction

   // ---- D10: a CONCATENATION operand (the § 12 zeroing arm)
   function void d10_concat(int sierra176);
      pipe176.one176({sierra176[15:0], sierra176[31:16]});   // a_concat
   endfunction

   // ---- D11: a NESTED CALL as the argument
   function int d11_nested(int tango176);
      pipe176.one176(helper176(tango176));        // a_nested_arg
      return owned176;
   endfunction
   function int helper176(int uni176);
      return uni176 + 1;
   endfunction

   // ---- D12: a FORK arm and a WHILE body
   task d12_fork(int vic176);
      fork
         pipe176.one176(vic176);                  // a_fork
      join_none
   endtask
   function void d13_while(int whis176);
      while (owned176 > 0) begin
         pipe176.one176(whis176);                 // a_while1
         owned176 = owned176 - 1;
      end
   endfunction
endclass

module top176;
   sink_if176 pan176();
   feeder176  fe176;
   initial begin
      fe176 = new();
      fe176.pipe176 = pan176;
      fe176.d1_depth0(1);
      fe176.d7_props();
      fe176.d9_shapes(2);
   end
endmodule
