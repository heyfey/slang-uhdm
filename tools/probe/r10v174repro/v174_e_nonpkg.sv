// r10v174repro arm E — THE NEGATIVE CONTROL, four non-package homes.
// `emitPackageClassMethodClones` is package-only, so `pkgClassTfClone` is null
// in a MODULE, an INTERFACE, a PROGRAM and at $unit scope: not one cell here
// may move.  (The module half is the implementer's stated residue R5 — it must
// stay exactly as wrong as it was, not get worse.)

// $unit-scope class with an out-of-body method.
class Loft;
  logic [15:0] rafter;
  extern function int eaveOut();
endclass
function int Loft::eaveOut();
  eaveOut = $bits(byte) + $bits(rafter) + $bits(int);
endfunction

function automatic int unitQuery();
  unitQuery = $bits(byte) + $bits(shortint);
endfunction

module gableTop;
  typedef logic [10:0] purlinWord;
  class Truss;
    logic [12:0] chord;
    extern function int webOut();
    function int webIn();
      webIn = $bits(byte) + $bits(chord) + $bits(purlinWord);
    endfunction
  endclass
  function int Truss::webOut();
    webOut = $bits(byte) + $bits(chord) + $bits(purlinWord) + $bits(int);
  endfunction
  function automatic int gableQuery();
    gableQuery = $bits(byte) + $bits(purlinWord);
  endfunction
endmodule

interface ridgeIf;
  typedef logic [8:0] battenWord;
  class Collar;
    logic [14:0] strut;
    extern function int tieOut();
  endclass
  function int Collar::tieOut();
    tieOut = $bits(byte) + $bits(strut) + $bits(battenWord);
  endfunction
  function automatic int ridgeQuery();
    ridgeQuery = $bits(byte) + $bits(battenWord);
  endfunction
endinterface

program soffitProg;
  class Fascia;
    logic [11:0] verge;
    extern function int boardOut();
  endclass
  function int Fascia::boardOut();
    boardOut = $bits(byte) + $bits(verge) + $bits(int);
  endfunction
endprogram
