// r10uvm191 grid ARM A — THE FACE AXIS.
//
// § cloneNewArrayArgBindsOwnDecl186 owns the DIRECT-NAME argument of a
// dynamic-array `new[...]` inside a wildcard-import clone.  This arm asks
// golden the same question one face over: what happens to the BASE of a
// `hier_path` written in that argument, for every RECEIVER KIND, and what
// happens to the element AFTER the base — which is where
// § pkgCloneMember10 and § builtinArrayReadBindsMintedFuncCall182 live and
// where a hop that reaches too far would show up as a MOVED-WRONG.
//
// One row per receiver kind: an ASSOCIATIVE array, a QUEUE, an UNPACKED
// fixed array, a DYNAMIC array, a STRUCT with a member actually called
// `size`, a QUEUE OF STRUCT, and — the FENCE — a CLASS PROPERTY at the
// identical face.  The parens-ful `.size()` and the parens-less `.size`
// spellings sit side by side in one function, because they serialise as two
// different element kinds (`method_func_call` vs `ref_obj`) and only the
// second can reach § 182's mint.
//
// Names, numbers and orders are deliberately unlike the corpus'.
package Trellis191;

  typedef struct packed {
    int hasp191;
    int size;              // a member SPELLED like the built-in method
  } Fascia191;

  int pkgtally191 = 9;

  class Newel191;
    int    m_hoard191[];                 // class property, dynamic array
    int    m_tally191[string];           // class property, associative
    extern function int gird191(input int fml_a);
    function int ream191(input int fml_b);      // IN BODY — never cloned
      int inner191[$];
      int dyn191[];
      inner191.push_back(fml_b);
      dyn191 = new[inner191.size()];     // A20 in-body method (control)
      return dyn191.size();
    endfunction
  endclass

  // OUT OF BODY — the corpus face (`function void uvm_packer::get_bytes`).
  function int Newel191::gird191(input int fml_a);
    int        dyn191[];
    int        bag191[string];      // ASSOC, function-level local
    int        rope191[$];          // QUEUE, function-level local
    int        slab191[4];          // UNPACKED fixed
    int        limb191[];           // DYNAMIC
    Fascia191  crate191;            // STRUCT with a `size` member
    Fascia191  nook191[$];          // QUEUE OF STRUCT

    bag191["a"] = 1;
    rope191.push_back(2);
    slab191[0] = 3;
    limb191 = new[2];
    crate191.hasp191 = 4;
    crate191.size = 5;
    nook191.push_back(crate191);

    dyn191 = new[bag191.size()];        // A1  ASSOC receiver, parens-ful
    dyn191 = new[rope191.size()];       // A2  QUEUE receiver, parens-ful
    dyn191 = new[slab191.sum()];        // A3  UNPACKED receiver, parens-ful
    dyn191 = new[limb191.size()];       // A4  DYNAMIC receiver, parens-ful
    dyn191 = new[m_hoard191.size()];    // A5  CLASS PROPERTY — THE FENCE
    dyn191 = new[m_tally191.size()];    // A6  CLASS PROPERTY, assoc — FENCE
    dyn191 = new[rope191.size];         // A7  PARENS-LESS (the § 182 face)
    dyn191 = new[nook191.size];         // A8  PARENS-LESS on a queue of struct
    dyn191 = new[crate191.size];        // A9  a struct MEMBER called `size`
    dyn191 = new[crate191.hasp191];     // A10 an ordinary struct MEMBER
    dyn191 = new[fml_a];                // A11 DIRECT NAME (§ 186's own cell)
    dyn191 = new[pkgtally191];          // A12 a PACKAGE variable (control)
    dyn191 = new[bag191.size()](limb191);   // A13 the COPY form, base in arg0
    dyn191 = new[fml_a](limb191);       // A14 the COPY form, direct name

    return dyn191.size() + slab191[0] + crate191.hasp191;
  endfunction

  function automatic int free191(input int fml_c);
    int dyn191[];
    int mesh191[string];
    mesh191["z"] = fml_c;
    dyn191 = new[mesh191.size()];       // A30 a FREE package function
    return dyn191.size();
  endfunction

endpackage

// WILDCARD import — the clone listing this law owns.
package Balustrade191;
  import Trellis191::*;
  int drift191 = 12;
  function automatic int use_bal191();
    Newel191 knob191;
    knob191 = new();
    return knob191.gird191(3) + knob191.ream191(4) + free191(5) + drift191;
  endfunction
endpackage

// EXPLICIT import — R1: golden treats this copy the same way and the shipped
// gate deliberately does not name it.
package Coping191;
  import Trellis191::free191;
  function automatic int use_cop191();
    return free191(6);
  endfunction
endpackage

module top191a;
  import Balustrade191::*;
  int scored191;
  initial begin
    scored191 = use_bal191();
    $display("%0d", scored191);
  end
endmodule
