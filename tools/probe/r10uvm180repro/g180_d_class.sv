// r10uvm180 arm D — THE CLASS GUARD.
// The gate stops the walk at a `class_defn` and at any typespec between the
// subroutine and the ref, because a `class_typespec` inside a clone body leads
// into the SHARED class world that both producers reach by other routes.  This
// arm makes the emitter take exactly those routes: a clone body that declares
// a class handle, calls a class method, and reads a class property whose type
// is the same package typedef the law moves elsewhere in the same body.
package cw180_holder;

  typedef logic [19:0] quartz_lt;
  typedef bit  [5:0]   schist_bt;

  class gneiss_c;
    quartz_lt  vein;
    schist_bt  ledge;
    function new();
      vein  = 20'h0_0001;
      ledge = 6'h01;
    endfunction
    function automatic quartz_lt widen(quartz_lt seam);
      quartz_lt tunnel;
      tunnel = seam | vein;
      begin
        quartz_lt sump;                 // inside a CLASS method: never moves
        sump = tunnel;
        tunnel = sump;
      end
      return tunnel;
    endfunction
  endclass

  // a FREE subroutine of the package: this body IS cloned, and it touches the
  // class world in three ways while also holding a plain block local.
  function automatic int unsigned gneiss_drive(quartz_lt seam);
    gneiss_c  rig;
    quartz_lt tunnel;
    rig    = new();
    tunnel = seam;
    if (tunnel != 0) begin
      quartz_lt sump;                   // this one DOES move (clone body)
      schist_bt cleat;                  // ...and so does this
      sump  = rig.widen(tunnel);
      cleat = rig.ledge;
      tunnel = sump ^ quartz_lt'(cleat);
    end
    return int'(tunnel);
  endfunction

endpackage

package cw180_taker;
  import cw180_holder::*;
endpackage

module cw180_top;
  import cw180_holder::*;
  quartz_lt shaft;
  int unsigned tally;
  initial begin
    shaft = 20'h1_2345;
    tally = gneiss_drive(shaft);
  end
endmodule
