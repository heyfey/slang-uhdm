// arm a13: the two things a process body can hold that ride ANOTHER law's
// flag, plus the object this pass deliberately does NOT mint.
//   * an ENUM CONSTANT reference — § uninstIfaceEnumConstNoActual221 rides
//     `uninstIfaceSubBody218`, and its producer argument (writeInterface never
//     calls lateBinding, and compile-time bindVariable walks only Variables()
//     and Io_decls()) is about the HOLDER, not about subroutines, so it must
//     answer the same inside a process body.
//   * a FOREACH header — § uninstIfaceForeachHdrUnresolved220, same flag.
//   * a CONCURRENT ASSERTION written as an interface item.  It is NOT a
//     process: writeInterface lists it under Assertions() from
//     mod->getAssertions(), a vector this pass does not touch.  The arm exists
//     to prove the fence, not to move the cell.
//   * an IMMEDIATE assertion INSIDE a process body — that one IS part of the
//     process's own statement tree.
interface if226_ea();
   typedef enum { E226_A, E226_B, E226_C } e226_t;
   e226_t  ev226;
   int     fa226 [4];
   int     q226;
   logic   clk226;

   initial begin
      ev226 = E226_A;                        // enum constant, assignment RHS
      if (ev226 == E226_B) q226 = 1;         // enum constant in a CONDITION
      case (ev226)
         E226_C: q226 = 2;                   // enum constant as a case ITEM
         default: q226 = 3;
      endcase
      foreach (fa226[i226])                  // a foreach header
         q226 += fa226[i226];
      assert (q226 > 0) else $error("a13");  // an IMMEDIATE assertion
   end

   // A CONCURRENT assertion as an interface ITEM (Assertions(), not Process()).
   assert property (@(posedge clk226) q226 >= 0);

   always_comb begin
      q226 = (ev226 == E226_A) ? 1 : 2;
   end
endinterface

// The INSTANTIATED twin, byte-identical body.
interface if226_eai();
   typedef enum { E226_A, E226_B, E226_C } e226_t;
   e226_t  ev226;
   int     fa226 [4];
   int     q226;
   logic   clk226;

   initial begin
      ev226 = E226_A;
      if (ev226 == E226_B) q226 = 1;
      case (ev226)
         E226_C: q226 = 2;
         default: q226 = 3;
      endcase
      foreach (fa226[i226])
         q226 += fa226[i226];
      assert (q226 > 0) else $error("a13");
   end

   assert property (@(posedge clk226) q226 >= 0);

   always_comb begin
      q226 = (ev226 == E226_A) ? 1 : 2;
   end
endinterface

module top226_ea;
   if226_eai u_eai226();
endmodule
