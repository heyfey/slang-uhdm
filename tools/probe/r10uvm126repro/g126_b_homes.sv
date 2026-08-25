// r10uvm126 grid B - DECLARATION HOME.  The same three non-integral element
// kinds (string / real / chandle) and one atom (byte) declared as a fixed-size
// unpacked array in EVERY home the emitter routes differently.  Sizes and
// names deliberately vary per home so no two cells can be confused.
package pk_bravo126;

  class Holder126;
    // (7) CLASS PROPERTY
    string  propStr126 [2];
    real    propReal126 [3];
    chandle propHnd126 [4];
    byte    propByte126 [5];

    // (1) IN-BODY CLASS TASK, block item
    task tsk126();
      string  tskStr126 [6];
      real    tskReal126 [7];
      chandle tskHnd126 [2];
      byte    tskByte126 [3];
      tskStr126[0] = "t";
      tskReal126[1] = 1.5;
      tskHnd126[0] = null;
      tskByte126[2] = 8'd1;
    endtask

    // (2) IN-BODY CLASS FUNCTION, block item
    function int fn126();
      string  fnStr126 [4];
      real    fnReal126 [5];
      chandle fnHnd126 [6];
      byte    fnByte126 [7];
      fnStr126[3] = "f";
      fnReal126[4] = 2.5;
      fnHnd126[5] = null;
      fnByte126[6] = 8'd2;
      return 0;
    endfunction

    // (6) NESTED begin-block local
    task blk126();
      begin : innerB126
        string  blkStr126 [3];
        real    blkReal126 [2];
        chandle blkHnd126 [5];
        byte    blkByte126 [4];
        blkStr126[2] = "b";
        blkReal126[1] = 3.5;
        blkHnd126[4] = null;
        blkByte126[3] = 8'd3;
      end
    endtask

    // (4) OUT-OF-BODY declaration
    extern function void oob126();
  endclass

  function void Holder126::oob126();
    string  oobStr126 [5];
    real    oobReal126 [4];
    chandle oobHnd126 [3];
    byte    oobByte126 [2];
    oobStr126[4] = "o";
    oobReal126[3] = 4.5;
    oobHnd126[2] = null;
    oobByte126[1] = 8'd4;
  endfunction

  // (3) PACKAGE FREE FUNCTION, block item
  function int pkgFn126();
    string  pfStr126 [7];
    real    pfReal126 [6];
    chandle pfHnd126 [5];
    byte    pfByte126 [4];
    pfStr126[6] = "p";
    pfReal126[5] = 5.5;
    pfHnd126[4] = null;
    pfByte126[3] = 8'd5;
    return 1;
  endfunction

  // (5) PAREN-LESS function - the TF-ITEM production
  function int noParen126;
    string  npStr126 [2];
    real    npReal126 [3];
    chandle npHnd126 [4];
    byte    npByte126 [5];
    npStr126[1] = "n";
    npReal126[2] = 6.5;
    npHnd126[3] = null;
    npByte126[4] = 8'd6;
    return 2;
  endfunction

  // (8) PACKAGE VARIABLE
  string  pkgStr126 [3];
  real    pkgReal126 [4];
  chandle pkgHnd126 [5];
  byte    pkgByte126 [6];

endpackage

module mod126;
  // (9) MODULE VARIABLE
  string  modStr126 [4];
  real    modReal126 [5];
  chandle modHnd126 [6];
  byte    modByte126 [7];

  // (10) MODULE TASK local
  task modTsk126();
    string  mtStr126 [5];
    real    mtReal126 [6];
    chandle mtHnd126 [7];
    byte    mtByte126 [2];
    mtStr126[4] = "m";
    mtReal126[5] = 7.5;
    mtHnd126[6] = null;
    mtByte126[1] = 8'd7;
  endtask

  // (11) FORMALS
  function int formals126(input string faStr126 [3],
                          input real faReal126 [2],
                          input byte faByte126 [4]);
    return 3;
  endfunction
endmodule
