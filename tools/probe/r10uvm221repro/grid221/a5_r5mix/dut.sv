// r10uvm221 arm a5_r5mix — THE COLLISION CHECK against
// § uninstIfaceBodyBindsInMethodWindow218's R4 and R5, and against
// § uninstIfaceForeachHdrUnresolved220.
//
//   R4 is THIS pass's population: enum-const actuals we mint in an
//       uninstantiated interface's body where golden has none.
//   R5 is the FOR-LOOP ITERATOR asymmetry: our iterators bind where the
//       PARSE-view golden leaves them bare while the ELAB-view golden binds
//       them.  If declining the enum-const mint touched an iterator, or the
//       iterator arm reached an enum constant, this arm would show it — every
//       cell below puts the two features in the SAME statement.
//   § 220 keeps the `foreach` header's placeholder; d10 in a4 and f01/f02 here
//       put an enum constant inside a foreach body and a foreach header's own
//       index expression.
//
// LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours.

package r221;
   typedef enum int {RE_A = 81, RE_B = 82, RE_C = 83} re221_t;
endpackage

interface ifr221u;                                    // NEVER INSTANTIATED
   import r221::*;
   int arr [0:9];
   re221_t earr [0:3];

   function int mix221(input int a_x);
      int loc;
      loc = 0;
      for (int i = 0; i < 2; i++) begin
         loc = loc + i;                               // r01 ITERATOR (R5)
         loc = loc + RE_A;                            // r02 enum const, same body
         if (i == 1) loc = loc + RE_B;                // r03 iterator + const, one cond
      end
      for (int j = RE_A; j < RE_B; j++) begin         // r04/r05 CONSTS IN THE HEADER
         loc = loc + j;                               // r06 ITERATOR (R5)
      end
      foreach (earr[k]) begin
         loc = loc + k;                               // r07 foreach index (§220)
         if (earr[k] == RE_C) loc = loc + 1;          // r08 enum const in foreach body
      end
      foreach (arr[m])
         loc = arr[m] + RE_A;                         // r09 const in a foreach body
      return loc;
   endfunction
endinterface

interface ifr221i;                                    // THE SAME BODY, INSTANTIATED
   import r221::*;
   int arr [0:9];
   re221_t earr [0:3];

   function int mix221(input int a_x);
      int loc;
      loc = 0;
      for (int i = 0; i < 2; i++) begin
         loc = loc + i;                               // r01
         loc = loc + RE_A;                            // r02
         if (i == 1) loc = loc + RE_B;                // r03
      end
      for (int j = RE_A; j < RE_B; j++) begin         // r04/r05
         loc = loc + j;                               // r06
      end
      foreach (earr[k]) begin
         loc = loc + k;                               // r07
         if (earr[k] == RE_C) loc = loc + 1;          // r08
      end
      foreach (arr[m])
         loc = arr[m] + RE_A;                         // r09
      return loc;
   endfunction
endinterface

module topr221;
   ifr221i u_ifr ();
endmodule
