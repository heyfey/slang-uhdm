// r10uvm191 grid ARM B — THE CONTEXT AXIS.
//
// The law's window is the DYNAMIC-ARRAY `new[...]` argument and nothing else,
// because that is the only place our emitter cuts the parent chain
// (§ newArray11 leaves the call unparented).  This arm writes the SAME
// receivers and the SAME method calls in every OTHER position a clone body
// can put them — a plain statement, an ordinary user call's argument, a
// SYSTEM call's argument, a `foreach` array reference, a select INDEX, an
// `if` condition, a `return` expression and a CLASS constructor's argument
// (`new(...)`, which is parented and must not be confused with `new[...]`) —
// so that "the law moved nothing outside its window" is a MEASURED column and
// not an assertion.  Every one of these cells must read UNTOUCHED.
//
// Names, numbers and orders are deliberately unlike the corpus'.
package Purlin191;

  int pkgcount191 = 3;

  class Corbel191;
    int m_ledge191[];
    extern function int splay191(input int fml_d);
  endclass

  function int Corbel191::splay191(input int fml_d);
    int  dyn191[];
    int  tally191[string];
    int  chain191[$];
    int  rack191[4];
    int  tot191;

    tally191["k"] = 1;
    chain191.push_back(2);
    rack191[0] = 3;
    tot191 = 0;

    tot191 = tally191.size();                 // B1  PLAIN statement rhs
    tot191 = tot191 + chain191.size();        // B2  an OPERATION operand
    tot191 = wedge191(tally191.size());       // B3  a USER call's argument
    $display("%0d", chain191.size());         // B4  a SYSTEM call's argument
    rack191[chain191.size()] = 4;             // B5  a select INDEX
    if (tally191.size() > 0)                  // B6  an `if` CONDITION
      tot191 = tot191 + 1;
    foreach (tally191[kk])                    // B7  a foreach ARRAY reference
      tot191 = tot191 + 1;
    while (chain191.size() > 9)               // B8  a `while` condition
      chain191.pop_front();
    case (tally191.size())                    // B9  a `case` selector
      0: tot191 = tot191;
      default: tot191 = tot191 + 1;
    endcase

    dyn191 = new[tally191.size()];            // B10 THE WINDOW (the mover)

    return tot191 + dyn191.size() + fml_d + m_ledge191.size();
  endfunction

  function automatic int wedge191(input int fml_e);
    return fml_e + 1;
  endfunction

  function automatic int hoop191(input int fml_f);
    Corbel191 cb191;
    int       spool191[$];
    spool191.push_back(fml_f);
    cb191 = new();                            // B11 the CLASS `new(...)` form
    return cb191.splay191(spool191.size());   // B12 a METHOD call's argument
  endfunction

endpackage

package Newelpost191;
  import Purlin191::*;
  int slack191 = 13;
  function automatic int use_np191();
    return hoop191(4) + slack191 + pkgcount191;
  endfunction
endpackage

module top191b;
  import Newelpost191::*;
  int scored191;
  initial begin
    scored191 = use_np191();
    $display("%0d", scored191);
  end
endmodule
