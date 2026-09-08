// r10uvm221 arm a1_ctx — THE CONTEXT MATRIX x {uninstantiated interface,
// INSTANTIATED interface, module}, all three holders in ONE design so ONE
// Surelog golden answers the whole grid.
//
// Every subroutine body below is the SAME TEXT.  The only thing that varies is
// the holder.  Each enum-constant reference carries a wNN tag in a comment so
// the census can be read cell by cell.
//
// LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours.

package p221;
   typedef enum int {PE_A = 1, PE_B = 2, PE_C = 3} pe221_t;
endpackage

typedef enum int {U_A = 7, U_B = 8} u221_t;      // a $unit-scope enum

interface if221u;                                 // NEVER INSTANTIATED
   import p221::*;
   typedef enum int {L_A = 4, L_B = 5} l221_t;    // the interface's OWN enum
   int             mvar;
   l221_t          evar;
   int             arr [0:9];

   function void sink221(int a_v);
   endfunction

   function int fn221(int a_v);
      return a_v;
   endfunction

   function int body221(input int a_x);
      int loc;
      l221_t eloc;
      loc = 0;
      if (a_x == L_A) loc = 1;                    // w01 condition, window
      loc = L_B;                                  // w03 plain assignment RHS
      sink221(L_A);                               // w04 call arg, stmt position
      loc = fn221(L_A);                           // w05 call arg, expr position
      if (a_x == 1) begin
         loc = L_A;                               // w06 one control body deeper
      end
      case (a_x)
         L_A: loc = 2;                            // w07 case ITEM
         default: loc = 3;
      endcase
      loc = arr[L_A];                             // w08 select index
      loc = L_A | L_B;                            // w09a/w09b operation operands
      $display("%0d", L_A);                       // w10 system-call argument
      loc = int'(L_A);                            // w11 cast operand
      while (loc != L_A) loc = loc + 1;           // w12 while condition
      for (int i = 0; i < 2; i++) loc = L_B;      // w13 for body
      loc = PE_A;                                 // w14 an IMPORTED package enum
      loc = p221::PE_B;                           // w15 a ::-QUALIFIED reference
      begin : nb221
         int nloc;
         nloc = L_A;                              // w16 named-block local target
         loc = nloc;
      end
      eloc = L_A;                                 // w17 assignment to an enum_var
      assert (loc != L_A);                        // w18 immediate assert condition
      loc = U_A;                                  // w19 a $unit-scope enum
      if (eloc inside {L_A, L_B}) loc = loc + 1;  // w20a/w20b an INSIDE SET
      if (a_x == 2)
         return L_A;                              // w02 RETURN — THE CORPUS SHAPE
      return loc;
   endfunction
endinterface

interface if221i;                                 // THE SAME BODY, INSTANTIATED
   import p221::*;
   typedef enum int {L_A = 4, L_B = 5} l221_t;
   int             mvar;
   l221_t          evar;
   int             arr [0:9];

   function void sink221(int a_v);
   endfunction

   function int fn221(int a_v);
      return a_v;
   endfunction

   function int body221(input int a_x);
      int loc;
      l221_t eloc;
      loc = 0;
      if (a_x == L_A) loc = 1;                    // w01
      loc = L_B;                                  // w03
      sink221(L_A);                               // w04
      loc = fn221(L_A);                           // w05
      if (a_x == 1) begin
         loc = L_A;                               // w06
      end
      case (a_x)
         L_A: loc = 2;                            // w07
         default: loc = 3;
      endcase
      loc = arr[L_A];                             // w08
      loc = L_A | L_B;                            // w09
      $display("%0d", L_A);                       // w10
      loc = int'(L_A);                            // w11
      while (loc != L_A) loc = loc + 1;           // w12
      for (int i = 0; i < 2; i++) loc = L_B;      // w13
      loc = PE_A;                                 // w14
      loc = p221::PE_B;                           // w15
      begin : nb221
         int nloc;
         nloc = L_A;                              // w16
         loc = nloc;
      end
      eloc = L_A;                                 // w17
      assert (loc != L_A);                        // w18
      loc = U_A;                                  // w19
      if (eloc inside {L_A, L_B}) loc = loc + 1;  // w20a/w20b
      if (a_x == 2)
         return L_A;                              // w02
      return loc;
   endfunction
endinterface

module m221;                                      // A MODULE — always elaborated
   import p221::*;
   typedef enum int {L_A = 4, L_B = 5} l221_t;
   int             mvar;
   l221_t          evar;
   int             arr [0:9];

   function void sink221(int a_v);
   endfunction

   function int fn221(int a_v);
      return a_v;
   endfunction

   function int body221(input int a_x);
      int loc;
      l221_t eloc;
      loc = 0;
      if (a_x == L_A) loc = 1;                    // w01
      loc = L_B;                                  // w03
      sink221(L_A);                               // w04
      loc = fn221(L_A);                           // w05
      if (a_x == 1) begin
         loc = L_A;                               // w06
      end
      case (a_x)
         L_A: loc = 2;                            // w07
         default: loc = 3;
      endcase
      loc = arr[L_A];                             // w08
      loc = L_A | L_B;                            // w09
      $display("%0d", L_A);                       // w10
      loc = int'(L_A);                            // w11
      while (loc != L_A) loc = loc + 1;           // w12
      for (int i = 0; i < 2; i++) loc = L_B;      // w13
      loc = PE_A;                                 // w14
      loc = p221::PE_B;                           // w15
      begin : nb221
         int nloc;
         nloc = L_A;                              // w16
         loc = nloc;
      end
      eloc = L_A;                                 // w17
      assert (loc != L_A);                        // w18
      loc = U_A;                                  // w19
      if (eloc inside {L_A, L_B}) loc = loc + 1;  // w20a/w20b
      if (a_x == 2)
         return L_A;                              // w02
      return loc;
   endfunction
endmodule

module top221;
   if221i  u_if ();                               // if221i IS instantiated
   m221    u_m  ();                               // m221   IS instantiated
endmodule
