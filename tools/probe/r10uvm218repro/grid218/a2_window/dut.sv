// r10uvm218 arm a2 — THE WINDOW BOUNDARY inside an UNINSTANTIATED interface.
// Every cell asks whether golden gives the reference a vpiActual, and the twin
// one control body deeper asks the DEPTH half.  The interface's OWN members are
// the OVER-FIRE control: if golden leaves them bare in a window, the law may
// not simply lift the silence for every symbol.
package q218;
   typedef enum { Q218_A, Q218_B } q218_t;
   localparam int Q218_K = 3;
endpackage

class d218;
   function void take(int x); endfunction
   function int  give(int x); return x; endfunction
endclass

interface if218_w;                          // NEVER instantiated
   import q218::*;
   bit  mvar218;                            // interface MEMBER (variable)
   wire mnet218;                            // interface MEMBER (net)
   localparam int MP218 = 7;                // interface localparam
   d218 h218;

   function void w218(int a_x, int a_y);
      int loc218;
      int arr218[4];
      // ---- WINDOW: if CONDITION, depth 0 -------------------------------
      if (a_x == 1) mvar218 = 1'b1;         // w01 formal        d0
      if (loc218 == 1) mvar218 = 1'b1;      // w02 body local    d0
      if (mvar218) mvar218 = 1'b0;          // w03 iface MEMBER var  d0
      if (mnet218) mvar218 = 1'b0;          // w04 iface MEMBER net  d0
      if (MP218 == 1) mvar218 = 1'b1;       // w05 iface localparam  d0
      if (Q218_K == 1) mvar218 = 1'b1;      // w06 package localparam d0
      if (a_x == Q218_A) mvar218 = 1'b1;    // w07 package enum const d0
      if (int'(a_y) == 1) mvar218 = 1'b1;   // w08 CAST operand      d0
      if (arr218[a_x] == 1) mvar218 = 1'b1; // w09 index of a select d0
      // ---- WINDOW: the DEPTH half --------------------------------------
      if (a_x == 2) begin
         if (a_y == 3) mvar218 = 1'b1;      // w10 formal in a cond, d1
         callee218(a_y);                    // w11 call-stmt arg,    d1
         loc218 = a_x;                      // w12 assign RHS,       d1
      end
      for (int i218 = 0; i218 < 2; i218++) begin
         if (a_x == 4) mvar218 = 1'b1;      // w13 formal in a cond, d1 (loop)
         callee218(i218);                   // w14 loop iterator arg d1
      end
      // ---- NOT A WINDOW: while / for CONDITION -------------------------
      while (a_x == 5) mvar218 = 1'b1;      // w15 WHILE condition   d0
      for (int j218 = 0; j218 < a_y; j218++) mvar218 = 1'b1; // w16 FOR cond
      // ---- WINDOW: CALL-STATEMENT arguments ----------------------------
      callee218(a_x);                       // w17 formal
      callee218(loc218);                    // w18 body local
      callee218(int'(mvar218));             // w19 iface MEMBER var
      callee218(int'(mnet218));             // w20 iface MEMBER net
      callee218(MP218);                     // w21 iface localparam
      callee218(a_x + a_y);                 // w22 formals under an OPERATION
      callee218({a_x, a_y} == 0);           // w23 CONCAT operand
      callee218($bits(a_x));                // w24 SYSTEM-call argument
      callee218(int'(a_x));                 // w25 CAST operand in an arg
      h218.take(a_x);                       // w26 RECEIVER-qualified, STMT pos
      // ---- NOT A WINDOW: EXPRESSION-position call ----------------------
      loc218 = fn218(a_x);                  // w27 plain call, EXPR position
      loc218 = h218.give(a_x);              // w28 RECEIVER call, EXPR position
      // ---- NAMED BLOCK -------------------------------------------------
      begin : nb218
         int nloc218;
         if (nloc218 == 1) mvar218 = 1'b1;  // w29 NAMED-block local in a cond
         callee218(nloc218);                // w30 NAMED-block local, call arg
      end
      // ---- UNNAMED BLOCK, same control depth ---------------------------
      begin
         int uloc218;
         if (uloc218 == 1) mvar218 = 1'b1;  // w31 unnamed-block local, cond
      end
   endfunction

   function void callee218(int z); endfunction
   function int  fn218(int z); return z; endfunction
endinterface

module top218w;                             // instantiates NOTHING of if218_w
   initial begin end
endmodule
