// r10uvm166 GRID D -- THE HOME AND SHAPE AXIS of the FIRING law.
// MEASUREMENT ONLY.  Every declaration here names a class- or module-homed
// unpacked-array typedef whose base is written as a NAME, from as many
// declaration homes and declaration shapes as the emitter has sites for.
package dk166;

  class Cog166;  int notch166; endclass
  typedef enum { EAST166, WEST166 } vane166_e;

  class Mill166;
    typedef vane166_e vaneQ166_t[$];
    typedef Cog166    cogD166_t[];
    typedef vane166_e vaneA166_t[string];
    typedef Cog166    cogF166_t[2];

    // IN-BODY method body top level
    function void grindIn166();
      vaneQ166_t inBodyVal166;
      cogD166_t  inDynVal166;
      vaneA166_t inAssocVal166;
      cogF166_t  inFixVal166;
    endfunction

    // IN-BODY task, nested begin / fork / loop / case
    task nestIn166(int sel166);
      begin
        vaneQ166_t nestVal166;
        fork
          begin
            vaneQ166_t forkVal166;
            forkVal166.delete();
          end
        join_none
        for (int i166 = 0; i166 < 2; i166++) begin
          vaneQ166_t loopVal166;
          loopVal166.delete();
        end
        case (sel166)
          0: begin
               vaneQ166_t caseVal166;
               caseVal166.delete();
             end
          default: ;
        endcase
        nestVal166.delete();
      end
    endtask

    // multiple declarators, const / static / automatic, initialiser
    function void shapesIn166();
      vaneQ166_t twoAVal166, twoBVal166;
      vaneQ166_t triAVal166, triBVal166, triCVal166;
      static vaneQ166_t statVal166;
      automatic vaneQ166_t autoVal166;
      vaneQ166_t initVal166 = twoAVal166;
      initVal166 = twoBVal166;
    endfunction

    extern function void grindOob166();
  endclass

  // OUT-OF-BODY method body
  function void Mill166::grindOob166();
    vaneQ166_t oobVal166;
    begin
      vaneQ166_t oobNestVal166;
      oobNestVal166.delete();
    end
    oobVal166.delete();
  endfunction

endpackage

module hub166;
  import dk166::*;
  typedef vane166_e hubQ166_t[$];
  typedef Cog166    hubF166_t[3];

  function automatic void spinMod166();
    hubQ166_t modFnVal166;
    hubF166_t modFixVal166;
  endfunction

  task automatic turnMod166();
    hubQ166_t modTaskVal166;
    modTaskVal166.delete();
  endtask

  initial begin
    hubQ166_t modInitVal166;
    modInitVal166.delete();
    spinMod166();
    turnMod166();
  end

  always_comb begin : blade166
    hubQ166_t modCombVal166;
    modCombVal166.delete();
  end
endmodule
