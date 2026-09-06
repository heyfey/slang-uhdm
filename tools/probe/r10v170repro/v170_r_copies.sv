// r10v170 arm R — THE COPY / CLONE / INSTANCE axis.  The law reads the
// SUBROUTINE's own declaring scope, so a wildcard-import CLONE re-emitted into
// another package is supposed to keep the same answer.  Three module instances
// and two importing packages make every copy path exist at once, and a
// NON-exported neighbour function in the SAME exporting package is the control
// that must survive every one of those re-emissions.
package CoreR5;
  typedef enum bit [1:0] { CR_A, CR_B } Grade_e;
  typedef enum bit [1:0] { CR_X, CR_Y } Trim_e;
  function void tapR5(int q);
  endfunction

  export "DPI-C" function hotR5;
  function void hotR5(int v);
    tapR5(int'(Grade_e'(v)));        // t01 exported, bare own enum
    tapR5(int'(CoreR5::Trim_e'(v))); // t02 exported, scoped own enum
  endfunction

  function void coldR5(int v);       // never exported -- the control
    tapR5(int'(Grade_e'(v)));        // t03
    tapR5(int'(CoreR5::Trim_e'(v))); // t04
  endfunction
endpackage

package WrapR5;                      // WILDCARD import -> clone copies
  import CoreR5::*;
  export CoreR5::*;
  function void relayR5(int v);
    tapR5(int'(Grade_e'(v)));        // t05 imported name, importing package
  endfunction
endpackage

package PickR5;                      // EXPLICIT import
  import CoreR5::Grade_e;
  import CoreR5::tapR5;
  function void pickR5(int v);
    tapR5(int'(Grade_e'(v)));        // t06
  endfunction
endpackage

module leafR5 #(parameter int SEED = 0) ();
  import CoreR5::*;
  initial begin
    hotR5(SEED);
    coldR5(SEED);
    tapR5(int'(Grade_e'(SEED)));     // t07 module scope, imported name
  end
endmodule

module topR170;
  leafR5 #(.SEED(1)) u_one ();
  leafR5 #(.SEED(2)) u_two ();
  leafR5 #(.SEED(3)) u_three ();
  initial begin
    WrapR5::relayR5(4);
    PickR5::pickR5(5);
  end
endmodule
