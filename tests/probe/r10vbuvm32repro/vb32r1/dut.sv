// vb32r1 — RISK ARM F2a: the written first segment is a PACKAGE that ALSO owns
// a FREE function with the final identifier's name.  Surelog's getTaskFunc
// first branch (CompileExpression.cpp:352-370) resolves `pr32::mcoll32`
// against the PACKAGE and HITS, so golden keeps the call even though the
// written qualifier is not the defining class.
package pr32;
  function void mcoll32(int a); $display("PKGFREE-V %0d", a); endfunction
  function int  fcoll32(int a); return a + 1; endfunction
  class hostr32;
    static int h32;
    extern static function void mcoll32(int a);
    extern static function int  fcoll32(int a);
    static function void inb32(int a); h32 += a; endfunction
  endclass
  function void hostr32::mcoll32(int a); h32 += a; endfunction
  function int  hostr32::fcoll32(int a); return a * 2; endfunction

  // control: a class method whose name has NO package free twin
  class hostr32b;
    static int h32b;
    extern static function void solo32(int a);
  endclass
  function void hostr32b::solo32(int a); h32b += a; endfunction
endpackage

module vb32r1;
  int r;
  initial begin
    pr32::hostr32::mcoll32(1);       // R1  pkg free twin EXISTS, out-of-body callee
    r = pr32::hostr32::fcoll32(2);   // R2  same, function in Rhs
    pr32::hostr32b::solo32(3);       // R3  CONTROL: no pkg free twin
    pr32::hostr32::inb32(4);         // R4  CONTROL: in-body callee
    pr32::mcoll32(5);                // R5  CONTROL: the package free function itself
    $display("%0d", r);
  end
endmodule
