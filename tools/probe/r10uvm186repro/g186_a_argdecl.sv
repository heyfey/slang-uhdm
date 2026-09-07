// r10uvm186 grid ARM A — THE ARGUMENT-DECLARATION AXIS of a dynamic-array
// `new[...]` argument, inside a WILDCARD-IMPORT CLONE.
//
// § newArrayArgNoBind16 says the whole argument list of `d = new[n]` stays
// BARE because Surelog never parents the `new` call, and its SYMBOL half
// (`newArraySubScopeSym16`) says only a SUBROUTINE-SCOPE name is in that
// silence — a class property, a package variable and a parameter answer
// FALSE and take their ordinary path.  § cloneNewArrayArgBindsOwnDecl186 says
// the silence is HOME-ONLY.  This arm asks golden the two questions at once,
// one row per declaration kind, in a free package function, a task and an
// OUT-OF-BODY class method (the corpus face is
// `function void uvm_packer::get_bytes`), for the SIZE argument and for the
// COPY SOURCE of `new[n](src)` alike.
//
// Names, numbers and orders are deliberately unlike the corpus'.
package Gantry186;

  typedef enum int { LATCH186 = 3, CLEAT186 = 5 } fitting186_e;

  parameter  int PLINTH186 = 4;
  localparam int SOFFIT186 = 6;
  int          pkgspan186 = 7;

  class Bollard186;
    int    m_girth;            // A14 — the class-property face (the FENCE)
    int    m_stash[];
    extern function int trim186(input int fml_w);      // out of body
    function int ream186(input int fml_y);             // in body
      int    dyn186[];
      int    loc186;
      loc186 = fml_y + 1;
      dyn186 = new[loc186];    // A16 in-body method, body local
      m_stash = new[m_girth];  // A17 in-body method, class property
      return dyn186.size() + m_stash.size();
    endfunction
  endclass

  function int Bollard186::trim186(input int fml_w);
    int  dyn186[];
    int  loc186;
    int  src186[];
    loc186 = fml_w + 2;
    src186 = new[3];
    dyn186 = new[loc186];        // A13 out-of-body method, BODY LOCAL
    m_stash = new[m_girth];      // A14 out-of-body method, CLASS PROPERTY
    dyn186 = new[fml_w];         // A15 out-of-body method, FORMAL
    dyn186 = new[loc186](src186);// A15b copy source, body local
    return dyn186.size();
  endfunction

  function automatic int spandrel186(input int fml_q, input int fml_src[]);
    int   dyn186[];
    int   loc186;
    int   src186[];
    int   idxbag186[4];
    static int stat186 = 2;
    loc186 = fml_q + 1;
    src186 = new[2];
    idxbag186[0] = 1;

    dyn186 = new[loc186];           // A1  function body local (automatic)
    dyn186 = new[fml_q];            // A2  FORMAL
    dyn186 = new[stat186];          // A3  function-level STATIC local
    dyn186 = new[pkgspan186];       // A4  PACKAGE variable
    dyn186 = new[PLINTH186];        // A5  package PARAMETER
    dyn186 = new[SOFFIT186];        // A6  package LOCALPARAM
    dyn186 = new[LATCH186];         // A7  ENUM CONSTANT
    dyn186 = new[loc186](src186);   // A8  COPY SOURCE, body local dyn array
    dyn186 = new[loc186](fml_src);  // A9  COPY SOURCE, a FORMAL dyn array
    dyn186 = new[loc186 + 1];       // A10 inside an OPERATION
    dyn186 = new[idxbag186[loc186]];// A11 a SELECT whose index is a local
    dyn186 = new[stub186(loc186)];  // A12 a nested call's own argument

    begin : hatch186
      int blk186;
      blk186 = 3;
      dyn186 = new[blk186];         // A17 NAMED-begin local
    end
    begin
      int nak186;
      nak186 = 4;
      dyn186 = new[nak186];         // A18 unnamed nested-begin local
    end
    for (int itr186 = 0; itr186 < 2; itr186++)
      dyn186 = new[itr186 + 1];     // A19 for-header ITERATOR (in an operation)
    foreach (idxbag186[fex186])
      dyn186 = new[fex186 + 1];     // A20 foreach INDEX (in an operation)

    return dyn186.size() + src186.size();
  endfunction

  function automatic int stub186(input int fml_z);
    return fml_z + 1;
  endfunction

  task automatic tromp186(input int fml_r, output int res186);
    int dyn186[];
    int loc186;
    loc186 = fml_r + 5;
    dyn186 = new[loc186];           // A21 a TASK's body local
    res186 = dyn186.size();
  endtask

endpackage

// WILDCARD import — the clone path the law owns.
package Stanchion186;
  import Gantry186::*;
  int drift186 = 11;
  function automatic int use_stanchion186();
    int      out186;
    int      feed186[];
    Bollard186 knob186;
    feed186 = new[2];
    knob186 = new();
    out186 = 0;
    return spandrel186(2, feed186) + out186 + knob186.trim186(3) +
           knob186.ream186(4);
  endfunction
  task automatic use_stanchion_t186(output int res186);
    tromp186(4, res186);
  endtask
endpackage

module top186a;
  import Stanchion186::*;
  int scored186;
  int tasked186;
  initial begin
    use_stanchion_t186(tasked186);
    scored186 = use_stanchion186() + tasked186;
    $display("%0d", scored186);
  end
endmodule
