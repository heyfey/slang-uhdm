// r10uvm184 grid ARM A — THE ARGUMENT AXIS OF A BUILT-IN METHOD CALL, IN A
// WILDCARD-IMPORT CLONE AND AT HOME.
//
// One home package holding a class with an out-of-body method and two free
// functions, and a WILDCARD importer, so every listing of the same call is in
// one database: the home package's own copy, the class listing's copy and the
// clone's two copies.  The ARGUMENT varies (subroutine LOCAL / FORMAL / CLASS
// PROPERTY / ENUM CONSTANT / literal / an OPERATION over a local), the
// argument POSITION varies (0 and 1), and the RECEIVER varies (a function
// local, a formal, a class property, the function's own return name).  The
// operation-wrapped argument is the arm's NEGATIVE control: it is not a direct
// `Tf_call_args` element, so the law must not touch it.
// Names, numbers and orders are deliberately unlike the corpus'.
package Quarry184;

  typedef enum bit [2:0] { SLATE184 = 1, BASALT184 = 2, GNEISS184 = 4 } grit_e;

  // ---- a free function: local receiver, every argument kind ----
  function automatic string chisel184(input int fml_a, input string fml_s);
    string  ledge;
    int     notch;
    int     rung;
    string  out;
    ledge = "quarrystone";
    notch = 2;
    rung  = 5;
    out = ledge.substr(1, notch);        // A1 local, arg1, local receiver
    out = ledge.substr(notch, 6);        // A2 local, arg0
    out = ledge.substr(1, fml_a);        // A3 formal, arg1
    out = ledge.substr(1, notch + rung); // A4 OPERATION — negative control
    out = ledge.substr(1, 4);            // A5 literal only — no name argument
    out = fml_s.substr(1, notch);        // A6 receiver is a FORMAL
    out = ledge.substr(notch, rung);     // A7 two name arguments at once
    return out;
  endfunction

  // ---- a free function whose RECEIVER is its own return name ----
  function automatic string trestle184(input int fml_b);
    int  span;
    span = 3;
    trestle184 = "trestlework";
    trestle184 = trestle184.substr(0, span);   // A8 return-name receiver
    trestle184 = trestle184.substr(span, 4);   // A9 same, arg0
    return trestle184;
  endfunction

  // ---- a class with an OUT-OF-BODY method: the head's own shape ----
  class Bollard184;
    int    m_girth;
    string m_brand;
    grit_e m_grade;
    extern function string plait184(input int fml_c);
    function string inbody184();               // IN-BODY twin, a control
      string  weave;
      int     pitch;
      weave = "inbodycord";
      pitch = 2;
      return weave.substr(1, pitch);           // A12 in-body class method
    endfunction
  endclass

  function string Bollard184::plait184(input int fml_c);
    string        cord;
    static string braid;
    int           twist;
    braid = "braidwork";
    cord  = "cordage";
    twist = 4;
    cord = braid.substr(1, twist);       // A10 local receiver, local arg
    cord = braid.substr(1, m_girth);     // A11 CLASS PROPERTY argument
    cord = m_brand.substr(1, twist);     // A13 class-property RECEIVER
    cord = braid.substr(1, fml_c);       // A14 formal argument
    cord = braid.substr(1, SLATE184);    // A15 ENUM CONSTANT argument
    return cord;
  endfunction

endpackage

// WILDCARD import — the clone path this law owns
package Bevel184;
  import Quarry184::*;
  int seen_bevel = 7;
  function automatic int use_bevel();
    Bollard184 stud;
    stud = new();
    return chisel184(3, "zz").len() + trestle184(4).len() +
           stud.plait184(9).len() + stud.inbody184().len();
  endfunction
endpackage

// EXPLICIT named import — a DIFFERENT copy path, and a control
package Fillet184;
  import Quarry184::chisel184;
  int seen_fillet = 8;
  function automatic int use_fillet();
    return chisel184(6, "yy").len();
  endfunction
endpackage

module top184;
  import Bevel184::*;
  import Fillet184::*;
  int tallied;
  initial begin
    tallied = use_bevel() + use_fillet();
    $display("%0d", tallied);
  end
endmodule
