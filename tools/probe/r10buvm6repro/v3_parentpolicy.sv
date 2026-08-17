// r10buvm6 arm 3 — the PARENTING question, INT twin against `$` twin.
//
// Arm 1 read golden's `$` constants and found FIVE parent outcomes:
//   bit_select index (plain, rvalue AND lvalue)   -> PARENTED to the bit_select
//   var_select index                              -> PARENTED to the var_select
//   operand of an index OPERATION (`$-1`)         -> PARENTED to the operation
//   part_select right range (`1:$`)               -> UNPARENTED
//   hier_path-element bit_select index (`t[$].f`) -> UNPARENTED
//
// The question this arm settles is whether that is a `$`-SPECIFIC policy or the
// SAME policy golden applies to an ordinary INTEGER index in the same five
// positions.  If the integer twins carry the identical parenting — and our
// pristine binary already matches golden on them — then the `$` arm must reuse
// the emitter's EXISTING constant-parenting predicate rather than invent one,
// and the arm PROVES it instead of asserting it.
//
// Each cell is a PAIR: `i##` is the integer twin, `d##` the `$` twin, in the
// same position, in the same kind of body.
package q6p;

  typedef struct {
    int f;
    int g;
  } q6st_t;

  class q6c;
    int      qi[$];
    q6st_t   qt[$];
    int      qn[2][$];
    int      sink[$];

    // ---- n01: plain bit_select index, rvalue
    function int i01(); int v; v = qi[1];  return v; endfunction
    function int d01(); int v; v = qi[$];  return v; endfunction

    // ---- n02: plain bit_select index, LVALUE
    function void i02(); qi[1] = 5; endfunction
    function void d02(); qi[$] = 5; endfunction

    // ---- n03: hier_path element bit_select index
    function int i03(); int v; v = qt[1].f; return v; endfunction
    function int d03(); int v; v = qt[$].f; return v; endfunction

    // ---- n04: var_select index (second dim)
    function int i04(); int v; v = qn[1][0]; return v; endfunction
    function int d04(); int v; v = qn[1][$]; return v; endfunction

    // ---- n05: part_select right range
    function void i05(); int r[$]; r = qi[1:2]; endfunction
    function void d05(); int r[$]; r = qi[1:$]; endfunction

    // ---- n06: operand of an index OPERATION
    function int i06(); int v; v = qi[2-1]; return v; endfunction
    function int d06(); int v; v = qi[$-1]; return v; endfunction

    // ---- n07: bit_select index as a METHOD-CALL argument (the corpus shape)
    function void i07(); sink.push_back(qi[1]); endfunction
    function void d07(); sink.push_back(qi[$]); endfunction

  endclass
endpackage
