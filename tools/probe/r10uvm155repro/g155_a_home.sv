// r10uvm155 grid, arm A — THE HOME AXIS.  One shape (a typedef declared in a
// STATEMENT scope, used by a declaration in that same scope) placed in every
// home this campaign can reach.  MEASUREMENT ONLY.
// Names are deliberately unlike each other (no a_t/b_t/c_t self-confirming
// grid): each home gets its own root, its own case and its own width.
package Hive155;
  typedef bit [2:0] hivePkgWidth;          // NEGATIVE control: a package typedef

  class Roost155;
    typedef bit [3:0] RoostMember;         // NEGATIVE control: a class typedef
    extern function void perch();

    // home 1: a BEGIN inside an IN-BODY class method
    function void nest();
      begin
        typedef bit [4:0] nestLocal_T;
        nestLocal_T nestVal;
        hivePkgWidth nestPkgVal;           // must RESOLVE
        RoostMember  nestClsVal;           // must RESOLVE
        nestVal = 0; nestPkgVal = 0; nestClsVal = 0;
      end
    endfunction

    // home 2: an IN-BODY class method's BODY TOP LEVEL
    function void brood();
      typedef bit [6:0] BROOD_T;
      BROOD_T broodVal;
      broodVal = 0;
    endfunction

    // home 3: a TASK body
    task feed();
      typedef bit [7:0] feed_t;
      feed_t feedVal;
      feedVal = 0;
    endtask
  endclass

  // home 4: an OUT-OF-BODY class method, body level AND a nested begin
  function void Roost155::perch();
    typedef bit [8:0] perchTop9;
    perchTop9 perchVal;
    begin
      typedef bit [9:0] perchInner10;
      perchInner10 perchInnerVal;
      perchInnerVal = 0;
    end
    perchVal = 0;
  endfunction

  // home 5: a PACKAGE FREE function
  function void flock();
    typedef bit [10:0] FlockKind;
    FlockKind flockVal;
    flockVal = 0;
  endfunction
endpackage

module Aviary155;
  // home 6: a module INITIAL body
  initial begin
    typedef bit [11:0] initialShade;
    initialShade initialVal;
    initialVal = 0;
  end

  // home 7: a module FUNCTION body
  function void wing();
    typedef bit [12:0] wing_TYPE;
    wing_TYPE wingVal;
    wingVal = 0;
  endfunction

  // home 8: a module TASK body
  task glide();
    typedef bit [13:0] Glide14;
    Glide14 glideVal;
    glideVal = 0;
  endtask

  // home 9: an ALWAYS_COMB body, and a NAMED begin inside it
  always_comb begin : plumage
    typedef bit [14:0] plumageWidth;
    plumageWidth plumageVal;
    plumageVal = 0;
  end

  // home 10: a FORK arm and a LOOP body and a CASE item
  initial begin
    fork
      begin
        typedef bit [15:0] forkArm_t;
        forkArm_t forkVal;
        forkVal = 0;
      end
    join_none
    for (int talon = 0; talon < 2; talon++) begin
      typedef bit [16:0] TALON_KIND;
      TALON_KIND talonVal;
      talonVal = 0;
    end
    case (1'b1)
      1'b1: begin
        typedef bit [17:0] beak18;
        beak18 beakVal;
        beakVal = 0;
      end
      default: ;
    endcase
  end

  // home 11: a GENERATE block's own begin (generate scopes are elaborated late)
  if (1) begin : eyrie
    initial begin
      typedef bit [18:0] eyrieShade;
      eyrieShade eyrieVal;
      eyrieVal = 0;
    end
  end
endmodule
