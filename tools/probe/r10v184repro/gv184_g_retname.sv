// r10v184 VERIFIER ARM G — THE DRAIN-ORDER CONFLICT FACE.
//
// § cloneBuiltinMethodArgBindsReceiver184's drain runs DEAD LAST, after every
// other design-final pool, so for the cells it owns it OVERRIDES whatever
// § 171 (the clone's return-name binder), § 26 / § 172 (call links) and the
// late class-property pool wrote.  That is only safe if golden agrees for
// every argument those pools also claim.  Arm A reads the function's own
// RETURN NAME as the RECEIVER; this arm reads it as the ARGUMENT, which is the
// one cell both § 171 and § 184 want to write.  It also reads a class property
// as an argument inside an out-of-body method (the late-bind pool's cell) and
// a call's own result feeding the next call.
// Names, numbers and orders are deliberately unlike the corpus'.
package Spandrel505;

  class Voussoir505;
    int    m_rise;
    string m_stone;
    extern function int keystone505(input int fml_k);
  endclass

  function int Voussoir505::keystone505(input int fml_k);
    string arch;
    arch = "archstone";
    keystone505 = 3;
    keystone505 = arch.getc(keystone505);   // G1 RETURN NAME as the ARGUMENT
    keystone505 = arch.getc(m_rise);        // G2 class property as the argument
    return keystone505;
  endfunction

  function automatic int impost505(input int fml_i);
    string  jamb;
    int     course;
    jamb   = "jambstone";
    course = 2;
    impost505 = 4;
    impost505 = jamb.getc(impost505);       // G3 RETURN NAME, free function
    impost505 = jamb.getc(course);          // G4 plain local, the control
    impost505 = jamb.getc(fml_i);           // G5 formal, the control
    return impost505;
  endfunction

endpackage

// WILDCARD import — the clone path the law owns.
package Squinch505;
  import Spandrel505::*;
  int seen_squinch505 = 41;
  function automatic int use_squinch505();
    Voussoir505 stone;
    stone = new();
    return impost505(9) + stone.keystone505(8);
  endfunction
endpackage

module top505;
  import Squinch505::*;
  int tally505;
  initial begin
    tally505 = use_squinch505();
    $display("%0d", tally505);
  end
endmodule
