// r10v110 arm v2c — FORMAL / MODULE-VARIABLE / LATE-DECLARED receivers, and the
// same module instantiated THREE times (DEF vs three ELAB copies).
package Fk2;
  class Hz;
    int  a[];
    byte b[];
    Hz   n;
    int  s;
  endclass
endpackage

module v2cmod;
  import Fk2::*;
  Hz modH;
  Hz lateH;
  int mw2;

  initial begin
    modH = new(); lateH = new(); mw2 = 2;
    modH.a  = new [mw2];        // v2c01 MODULE variable receiver     (in law)
    lateH.b = new [3];          // v2c02 second module receiver       (in law)
    modH.s  = 4;                // v2c03 control
  end

  task automatic tk2c(input Hz ip2, ref Hz rp2, inout Hz xp2);
    ip2.a = new [5];            // v2c04 INPUT formal receiver        (in law)
    rp2.b = new [6];            // v2c05 REF formal receiver          (in law)
    xp2.a = new [7];            // v2c06 INOUT formal receiver        (in law)
    ip2.s = 5;                  // v2c07 control
  endtask

  function automatic void fn2c(Hz fh2);
    fh2.b = new [8];            // v2c08 function formal receiver     (in law)
  endfunction
endmodule

module v2ctop;
  v2cmod A1();
  v2cmod A2();
  v2cmod A3();
endmodule
