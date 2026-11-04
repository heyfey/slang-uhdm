// arm a15: THE BINDING WINDOW OF A PROCESS BODY in an UNINSTANTIATED
// interface.  a7's `if226_b` DEF[1] showed golden BINDING an unnamed-block
// local read in a CASE CONDITION while leaving the same variable bare on an
// assignment LHS — the § refVarLocalWindowBinds5 / § uninstIfaceBodyBinds-
// InMethodWindow218 window shape, in a body that is not a subroutine at all.
// This arm reads every position x every referent kind so the window's exact
// edges are measured and not transcribed.
//
// Referent kinds (columns):  M = interface member variable, N = member net,
//   L = localparam, P = parameter, U = local declared in the process's own
//   UNNAMED outer block, B = local declared in a NAMED block, D = local
//   declared in an unnamed block ONE control level deeper.
// Positions (rows) are labelled in the comments; each cell is one reference.
interface if226_w();
   localparam int L226 = 5;
   parameter  int P226 = 6;
   logic          m226;
   wire           n226;
   int            q226;
   int            arr226 [4];

   function automatic int f226(int a226); return a226; endfunction
   task     automatic void_t226(int a226); q226 = a226; endtask

   always @(m226) begin
      int u226;                              // U: unnamed outer block, depth 0
      u226 = 1;                              // w01 assignment LHS  (U)
      q226 = u226;                           // w02 assignment RHS  (U)
      if (u226 == 1) q226 = 1;               // w03 IF condition    (U)
      case (u226)                            // w04 CASE condition  (U)
         1: q226 = 1;
         default: q226 = 2;
      endcase
      case (q226)
         u226: q226 = 3;                     // w05 CASE ITEM expr  (U)
         default: q226 = 4;
      endcase
      while (u226 < 2) q226 = 5;             // w06 WHILE condition (U)
      for (int k226 = 0; k226 < u226; k226++) q226 = 6;  // w07 FOR condition (U)
      q226 = f226(u226);                     // w08 user FUNCTION arg (U)
      void_t226(u226);                       // w09 user TASK arg     (U)
      $display("%0d", u226);                 // w10 SYSTEM call arg   (U)
      assert (u226 > 0);                     // w11 IMMEDIATE assert cond (U)
      q226 = int'(u226);                     // w12 CAST operand      (U)

      if (m226 == 1'b1) q226 = 7;            // w13 IF condition    (M)
      if (n226 == 1'b1) q226 = 8;            // w14 IF condition    (N)
      if (L226 == 5)    q226 = 9;            // w15 IF condition    (L)
      if (P226 == 6)    q226 = 10;           // w16 IF condition    (P)
      q226 = f226(m226);                     // w17 FUNCTION arg    (M)
      q226 = f226(L226);                     // w18 FUNCTION arg    (L)

      if (q226 == 1) begin
         int d226;                           // D: one control level deeper
         d226 = 1;                           // w19 assignment LHS  (D)
         if (d226 == 1) q226 = 11;           // w20 IF condition    (D)
         q226 = f226(d226);                  // w21 FUNCTION arg    (D)
         if (u226 == 1) q226 = 12;           // w22 IF condition    (U, depth 1)
         q226 = f226(u226);                  // w23 FUNCTION arg    (U, depth 1)
      end
   end

   initial begin : nb226
      automatic int b226 = 1;                // B: NAMED block local
      b226 = 2;                              // w24 assignment LHS  (B)
      if (b226 == 1) q226 = 13;              // w25 IF condition    (B)
      q226 = f226(b226);                     // w26 FUNCTION arg    (B)
      case (b226)                            // w27 CASE condition  (B)
         1: q226 = 14;
         default: q226 = 15;
      endcase
   end

   always_comb begin
      int e226;
      e226 = q226;
      if (e226 == 1) q226 = 16;              // w28 IF condition (U) in always_comb
   end
endinterface

// The INSTANTIATED twin, byte-identical body — the control column.
interface if226_wi();
   localparam int L226 = 5;
   parameter  int P226 = 6;
   logic          m226;
   wire           n226;
   int            q226;
   int            arr226 [4];

   function automatic int f226(int a226); return a226; endfunction
   task     automatic void_t226(int a226); q226 = a226; endtask

   always @(m226) begin
      int u226;
      u226 = 1;
      q226 = u226;
      if (u226 == 1) q226 = 1;
      case (u226)
         1: q226 = 1;
         default: q226 = 2;
      endcase
      case (q226)
         u226: q226 = 3;
         default: q226 = 4;
      endcase
      while (u226 < 2) q226 = 5;
      for (int k226 = 0; k226 < u226; k226++) q226 = 6;
      q226 = f226(u226);
      void_t226(u226);
      $display("%0d", u226);
      assert (u226 > 0);
      q226 = int'(u226);

      if (m226 == 1'b1) q226 = 7;
      if (n226 == 1'b1) q226 = 8;
      if (L226 == 5)    q226 = 9;
      if (P226 == 6)    q226 = 10;
      q226 = f226(m226);
      q226 = f226(L226);

      if (q226 == 1) begin
         int d226;
         d226 = 1;
         if (d226 == 1) q226 = 11;
         q226 = f226(d226);
         if (u226 == 1) q226 = 12;
         q226 = f226(u226);
      end
   end

   initial begin : nb226
      automatic int b226 = 1;
      b226 = 2;
      if (b226 == 1) q226 = 13;
      q226 = f226(b226);
      case (b226)
         1: q226 = 14;
         default: q226 = 15;
      endcase
   end

   always_comb begin
      int e226;
      e226 = q226;
      if (e226 == 1) q226 = 16;
   end
endinterface

module top226_w;
   if226_wi u_wi226();
endmodule
