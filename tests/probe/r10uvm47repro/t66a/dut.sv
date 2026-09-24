// r10uvm47 arm t66a — the NEXT head, exposed by § pkgInitRefBindsOwnListing47:
// a reference to a PACKAGE PARAMETER from inside a CLASS METHOD BODY.
//
// Measured head after target 1 (LHS golden(Surelog), RHS ours), IDENTICAL on
// SeqDriver, SimpleUVM and Scoreboard:
//
//   LHS: ref_obj (uvm_pkg::uvm_comparer::compare_field::UVM_STREAMBITS),
//        line 154:15-154:29, vpiParent = operation 154:15-154:34,
//        vpiName UVM_STREAMBITS, and NOTHING else — no vpiActual, no typespec
//   RHS: constant 4096, vpiSize 32, vpiConstType 9
//
// Source: `parameter UVM_STREAMBITS = `UVM_MAX_STREAMBITS;` at
// base/uvm_object_globals.svh:39 (an IMPLICITLY typed package parameter),
// read at base/uvm_comparer.svh:154 inside `uvm_comparer::compare_field`'s body
// as `mask >>= (UVM_STREAMBITS-size);`.
//
// The candidate keys, each given its own cell AND its own control, because the
// uvm site has FOUR properties at once and any one of them could be the gate:
//   K1  the reader is a CLASS METHOD body           vs a package FUNCTION body
//   K2  the referent is a `parameter`               vs a `localparam`
//   K3  the referent is IMPLICITLY typed            vs explicitly `int`/`logic`
//   K4  the reference sits inside an OPERATION      vs standing alone
// plus: a MODULE body reader, a class PROPERTY initialiser reader, and a
// reference used as a RANGE bound (the uvm_bitstream_t typedef spelling), since
// a fold there would be a different code path.
package s1;

  parameter  P_IMPL      = 4096;         // K2=parameter, K3=implicit  <- uvm's
  parameter  int P_TYPED = 4096;         // K3 control: explicitly typed
  localparam L_IMPL      = 4096;         // K2 control: localparam
  localparam int L_TYPED = 4096;

  typedef logic signed [P_IMPL-1:0] bs_t; // range-bound spelling

  class rdr;
    int prop_init = P_IMPL;              // class PROPERTY initialiser reader
    bs_t mask;

    // K1 = class method body.  K4 both ways in one method.
    function int m_op(int size);
      int a;
      a = P_IMPL - size;                 // K4=in an operation  <- uvm's
      return a;
    endfunction

    function int m_alone();
      int b;
      b = P_IMPL;                        // K4 control: stands alone
      return b;
    endfunction

    function int m_typed(int size);
      int c;
      c = P_TYPED - size;                // K3 control inside a class method
      return c;
    endfunction

    function int m_local(int size);
      int d;
      d = L_IMPL - size;                 // K2 control inside a class method
      return d;
    endfunction

    function int m_shift(int size);
      bs_t e;
      e = -1;
      e >>= (P_IMPL - size);             // uvm's EXACT statement shape
      return e[31:0];
    endfunction
  endclass

  // K1 control: a package FUNCTION body, same expression.
  function automatic int f_op(int size);
    int a;
    a = P_IMPL - size;
    return a;
  endfunction

endpackage

module t66a;
  import s1::*;
  // K1 control: a MODULE body reader.
  int m_read;
  initial begin
    rdr r = new();
    m_read = P_IMPL - 1;
    $display("%0d %0d %0d %0d %0d %0d %0d", r.m_op(3), r.m_alone(),
             r.m_typed(3), r.m_local(3), r.m_shift(3), f_op(3), m_read);
  end
endmodule
