// r10v174repro arm A (bare `bit`/`logic` and inline vector TYPE operands are
// [ERR:UH0700] in Surelog itself — golden is unusable for them, so the vector
// faces are carried by the typedefs and by the declared variables) — THE FOLD FACES, three homes, names and order chosen to
// share nothing with the implementer's g174_a_forms.sv.
// Golden = Surelog.  The DEF listing of quarryPkg carries Flint::outerQuery /
// Flint::outerTask as `C::m` clones; the ELAB listing files them under the
// class_defn.  Every $bits face is written in BOTH an out-of-body method and
// an in-block twin so the split is read, not assumed.
package quarryPkg;

  typedef logic [11:0] tallowBus;
  typedef byte         hodMask [4];
  parameter  int RASP   = 40;
  localparam int GROTTO = 12;

  class Flint;
    typedef bit [6:0] emberIdx;
    logic [23:0] plinth;
    tallowBus    vane;
    Flint        nib;
    localparam int WISP = 9;
    real   quill;
    time   clepsydra;
    static int lodge = 3;

    extern function int outerQuery(input logic [4:0] hasp);
    extern task outerTask(input int spar);

    // The IN-BLOCK twin of outerQuery, same faces, same order.
    function int innerQuery(input logic [4:0] hasp);
      int drift;
      innerQuery = $bits(byte) + $bits(int) + $bits(shortint) + $bits(longint)
                 + $bits(integer)
                 + $bits(tallowBus) + $bits(hodMask) + $bits(emberIdx)
                 + $bits(plinth) + $bits(vane)
                 + $bits(drift) + $bits(hasp)
                 + $bits(WISP) + $bits(GROTTO) + $bits(RASP)
                 + $bits(hasp + 1) + $bits(quill) + $bits(clepsydra)
                 + $bits(lodge);
    endfunction
  endclass

  // OUT-OF-BODY METHOD — the window the gate opens.
  function int Flint::outerQuery(input logic [4:0] hasp);
    int drift;
    outerQuery = $bits(byte) + $bits(int) + $bits(shortint) + $bits(longint)
               + $bits(integer)
               + $bits(tallowBus) + $bits(hodMask) + $bits(emberIdx)
               + $bits(plinth) + $bits(vane)
               + $bits(drift) + $bits(hasp)
               + $bits(WISP) + $bits(GROTTO) + $bits(RASP)
               + $bits(hasp + 1) + $bits(quill) + $bits(clepsydra)
               + $bits(lodge);
  endfunction

  // OUT-OF-BODY TASK — same window, second instance.
  task Flint::outerTask(input int spar);
    int cobble;
    cobble = $bits(byte) + $bits(plinth) + $bits(spar) + $bits(tallowBus)
           + $bits(hodMask) + $bits(RASP);
  endtask

  // A FREE package function — same listing, NOT a class-method clone.
  function automatic int freeQuery(input int chock);
    freeQuery = $bits(byte) + $bits(tallowBus) + $bits(chock) + $bits(RASP)
              + $bits(chock + 1);
  endfunction

endpackage

module quarryTop; quarryPkg::Flint fl = new(); int r; initial r = fl.outerQuery(5'd3) + fl.innerQuery(5'd2) + quarryPkg::freeQuery(7); endmodule
