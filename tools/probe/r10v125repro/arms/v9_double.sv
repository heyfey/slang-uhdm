// v125 arm V9 — the DOUBLE-CONVERSION family: slang can wrap the copy-back
// placeholder in TWO nested Conversions (Conversion(Conversion(EmptyArgument))),
// which slang's own isLValueArg() does NOT name.
package Dbl_Pkg;
  typedef enum logic [2:0] { D_A, D_B, D_C } Dcode;
  typedef enum int { I_A, I_B } Icode;
  function automatic int eOut(output Dcode v); v = D_B; return 0; endfunction
  function automatic int iOut(output Icode v); v = I_B; return 0; endfunction
  function automatic int nOut(output int   v); v = 3;   return 0; endfunction
  function automatic int rOut(output real  v); v = 1.0; return 0; endfunction

  class Dbl_User;
    int          rc;
    Dcode        exactEnum;
    logic [1:0]  narrowBits;
    logic [7:0]  wideBits;
    int          intSlot;
    integer      integerSlot;
    real         realSlot;
    shortreal    shortSlot;
    byte         byteSlot;
    Icode        exactIcode;
    function void run();
      rc = eOut(exactEnum);    // matching enum
      rc = eOut(narrowBits);   // enum -> 2 bits
      rc = eOut(wideBits);     // enum -> 8 bits
      rc = eOut(intSlot);      // enum -> int
      rc = iOut(exactIcode);   // matching int-based enum
      rc = iOut(intSlot);      // int-enum -> int
      rc = iOut(byteSlot);     // int-enum -> byte
      rc = nOut(intSlot);      // matching int
      rc = nOut(integerSlot);  // int -> integer
      rc = nOut(realSlot);     // int -> real
      rc = nOut(narrowBits);   // int -> 2 bits
      rc = rOut(realSlot);     // matching real
      rc = rOut(shortSlot);    // real -> shortreal
      rc = rOut(intSlot);      // real -> int
    endfunction
  endclass
endpackage
