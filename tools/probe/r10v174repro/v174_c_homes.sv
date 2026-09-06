// r10v174repro arm C — THE HOMES, and the AWAY-risk positions.
// Which of a package's DEF-listing bodies the gate may open, and — the point
// of this arm — the positions inside an out-of-body method where a fold could
// legitimately survive `Reduce::No` and where an over-wide gate would push us
// AWAY from golden: a function-local localparam, a declaration RANGE, a loop
// bound, a case item, a static-lifetime initializer, and a default argument.
package trestlePkg;

  typedef logic [13:0] gantryWord;
  parameter  int SPAR   = $bits(gantryWord);   // package parameter initializer
  localparam int BOLLARD = $bits(byte) * 2;    // package localparam initializer
  int   dunnage = $bits(byte);                 // package VARIABLE initializer
  logic [$bits(gantryWord)-1:0] scupper;       // package net/var decl RANGE

  class Bosun;
    int  keelson = $bits(byte);                // class-property initializer
    logic [7:0] warp;
    extern function new(input int gaff = $bits(byte));
    extern function int hawseOut();
    extern task hawseOutTask();
    function int hawseIn();
      hawseIn = $bits(byte) + $bits(warp);
    endfunction
  endclass

  // OUT-OF-BODY CONSTRUCTOR.
  function Bosun::new(input int gaff = $bits(byte));
    keelson = gaff + $bits(byte);
  endfunction

  // OUT-OF-BODY METHOD, carrying the AWAY-risk positions.
  function int Bosun::hawseOut();
    localparam int MIZZEN = $bits(byte);            // function-local localparam
    logic [$bits(gantryWord)-1:0] futtock;          // declaration RANGE
    int tally;
    tally = 0;
    for (int i = 0; i < $bits(byte); i++)           // loop bound
      tally += i;
    case (tally)
      $bits(byte): tally = 1;                       // case item
      default:     tally = 2;
    endcase
    hawseOut = MIZZEN + $bits(futtock) + tally + $bits(warp);
  endfunction

  // OUT-OF-BODY TASK, second instance.
  task Bosun::hawseOutTask();
    logic [$bits(gantryWord)-1:0] cathead;
    cathead = $bits(byte);
  endtask

  // FREE package function and FREE package task — same DEF listing, no clone.
  function automatic int freeHawse();
    freeHawse = $bits(byte) + $bits(gantryWord) + SPAR + BOLLARD;
  endfunction

  task automatic freeHawseTask();
    int rove;
    rove = $bits(byte) + $bits(gantryWord);
  endtask

endpackage

module trestleTop; trestlePkg::Bosun bs = new(); int r; initial r = bs.hawseOut() + bs.hawseIn() + trestlePkg::freeHawse(); endmodule
