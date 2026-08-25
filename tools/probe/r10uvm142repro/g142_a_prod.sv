// r10uvm142 arm A — THE PRODUCTION AXIS.
// One class-handle local per (subroutine home x written header shape), the
// class ALWAYS in the SAME package as the subroutine.  The head's own shape is
// `oobtf_*` (an out-of-body class method with a PAREN-LESS header).
// Cell names encode: <home><production>_<n / i>  (n = no initialiser,
// i = with an initialiser, the head's own spelling).
package pa142;

  class Ka142;
    static function Ka142 get_inst();
      Ka142 r = null;
      return r;
    endfunction
  endclass

  class Ha142;
    // IN-BODY, TF-ITEM production (paren-less function header)
    function void ibtf;
      Ka142 ibtf_n;
      Ka142 ibtf_i = Ka142::get_inst();
    endfunction
    // IN-BODY, BLOCK production (paren'd function header)
    function void ibbl();
      Ka142 ibbl_n;
      Ka142 ibbl_i = Ka142::get_inst();
    endfunction
    // IN-BODY task: BLOCK production (no body io decl)
    task ibtk;
      Ka142 ibtk_n;
      Ka142 ibtk_i = Ka142::get_inst();
    endtask
    // IN-BODY task with a BODY io declaration: TF-ITEM production
    task ibtkio;
      input int qa142;
      Ka142 ibtkio_n;
      Ka142 ibtkio_i = Ka142::get_inst();
    endtask
    extern function void oobtf;
    extern function void oobbl();
    extern task oobtk;
    extern task oobtkio(input int qb142);
  endclass

  // OUT-OF-BODY, TF-ITEM production  <- THE HEAD'S OWN SHAPE
  function void Ha142::oobtf;
    Ka142 oobtf_n;
    Ka142 oobtf_i = Ka142::get_inst();
  endfunction
  // OUT-OF-BODY, BLOCK production
  function void Ha142::oobbl();
    Ka142 oobbl_n;
    Ka142 oobbl_i = Ka142::get_inst();
  endfunction
  task Ha142::oobtk;
    Ka142 oobtk_n;
    Ka142 oobtk_i = Ka142::get_inst();
  endtask
  task Ha142::oobtkio;
    input int qb142;
    Ka142 oobtkio_n;
    Ka142 oobtkio_i = Ka142::get_inst();
  endtask

  // PACKAGE FREE function / task, both productions
  function void pftf;
    Ka142 pftf_n;
    Ka142 pftf_i = Ka142::get_inst();
  endfunction
  function void pfbl();
    Ka142 pfbl_n;
    Ka142 pfbl_i = Ka142::get_inst();
  endfunction
  task pftk;
    Ka142 pftk_n;
    Ka142 pftk_i = Ka142::get_inst();
  endtask
  task pftkio;
    input int qc142;
    Ka142 pftkio_n;
    Ka142 pftkio_i = Ka142::get_inst();
  endtask

  // A PACKAGE-scope variable and a CLASS PROPERTY: the non-local controls.
  Ka142 pkgvar142;
endpackage

// The same two productions in a MODULE, in a MODULE's class, and at $unit.
class Ua142;
  static function Ua142 get_inst();
    Ua142 r = null;
    return r;
  endfunction
endclass

function void utf142;
  Ua142 utf_n;
  Ua142 utf_i = Ua142::get_inst();
endfunction
function void ubl142();
  Ua142 ubl_n;
  Ua142 ubl_i = Ua142::get_inst();
endfunction

module ma142;
  class Ma142;
    static function Ma142 get_inst();
      Ma142 r = null;
      return r;
    endfunction
  endclass
  Ma142 modvar142;
  function void mtf;
    Ma142 mtf_n;
    Ma142 mtf_i = Ma142::get_inst();
  endfunction
  function void mbl();
    Ma142 mbl_n;
    Ma142 mbl_i = Ma142::get_inst();
  endfunction
  task mtk;
    Ma142 mtk_n;
  endtask
  task mtkio;
    input int qd142;
    Ma142 mtkio_n;
  endtask
  class Mh142;
    function void mibtf;
      Ma142 mibtf_n;
    endfunction
    function void mibbl();
      Ma142 mibbl_n;
    endfunction
    extern function void moobtf;
    extern function void moobbl();
  endclass
  function void Mh142::moobtf;
    Ma142 moobtf_n;
  endfunction
  function void Mh142::moobbl();
    Ma142 moobbl_n;
  endfunction
endmodule
