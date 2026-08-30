// r10v161 ARM F — THE CONCATENATION COLUMN.  Arm E caught `assert ({a,b}==0)`
// binding its operands where golden leaves them bare, WITHOUT any cast and
// WITHOUT any named block: a third pristine-right / patched-wrong family that
// belongs to § 161's window itself.  This arm isolates it: the same operand in
// an `if` CONDITION, an ASSERT condition, a CASE condition and a CASE ITEM,
// concatenated and bare, packed and unpacked, in and out of a class method.
// MEASUREMENT ONLY.  LHS golden (Surelog), RHS ours.
class Cat_f161;
  int prop = 1;

  function void f_cat(int formal_f);
    int loc = 1;
    bit [3:0] nib = 0;
    bit [3:0] nib2 = 0;
    logic [7:0] byt = 0;
    // ---- the `if` COLUMN ------------------------------------------------
    if (nib == 0) prop = 1;                     // f01 packed local, BARE operand
    if (loc == 1) prop = 1;                     // f02 int local (control)
    if ({nib, nib2} == 0) prop = 1;             // f03 a CONCAT of two packed locals
    if ({loc, loc} == 0) prop = 1;              // f04 a CONCAT of two int locals
    if ({2{nib}} == 0) prop = 1;                // f05 a REPLICATION
    if ({nib, 4'h0} == 0) prop = 1;             // f06 a CONCAT with a literal
    if ({byt[3:0], nib} == 0) prop = 1;         // f07 a CONCAT with a part select
    if ((nib + nib2) == 0) prop = 1;            // f08 a plain OPERATION (control)
    // ---- the ASSERT COLUMN ----------------------------------------------
    assert (nib == 0);                          // f11
    assert (loc == 1);                          // f12
    assert ({nib, nib2} == 0);                  // f13
    assert ({loc, loc} == 0);                   // f14
    assert ({2{nib}} == 0);                     // f15
    assert ({nib, 4'h0} == 0);                  // f16
    assert ({byt[3:0], nib} == 0);              // f17
    assert ((nib + nib2) == 0);                 // f18
    assert (formal_f == 1);                     // f19
    assert ({formal_f, formal_f} == 0);         // f20 a CONCAT of FORMALS
    // ---- the CASE CONDITION and CASE ITEM columns -----------------------
    case ({nib, nib2})                          // f21 a CONCAT as the case CONDITION
      8'h00: prop = 1;
      default: prop = 0;
    endcase
    case (byt)
      {nib, nib2}: prop = 1;                    // f22 a CONCAT as a case ITEM
      {loc[3:0], loc[3:0]}: prop = 2;           // f23
      default: prop = 0;
    endcase
  endfunction

  extern function void f_oob_cat();
endclass

function void Cat_f161::f_oob_cat();
  bit [3:0] onib = 0;
  bit [3:0] onib2 = 0;
  if ({onib, onib2} == 0) prop = 1;             // f31 OUT-OF-BODY, if column
  assert ({onib, onib2} == 0);                  // f32 OUT-OF-BODY, assert column
  assert (onib == 0);                           // f33 OUT-OF-BODY, bare operand
endfunction

module top_f161;
  Cat_f161 cf;
  bit [3:0] mnib = 0;

  function automatic int mod_fn_f();
    bit [3:0] fnib = 0;
    bit [3:0] fnib2 = 0;
    if ({fnib, fnib2} == 0) return 1;           // f41 MODULE function, if column
    assert ({fnib, fnib2} == 0);                // f42 MODULE function, assert column
    assert (fnib == 0);                         // f43
    return 0;
  endfunction

  initial begin
    cf = new();
    if (mod_fn_f() == 1) mnib = 1;
  end
endmodule
