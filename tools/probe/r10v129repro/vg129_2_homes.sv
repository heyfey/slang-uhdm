// r10v129 verifier grid 2 - the SAME named element type (a package enum
// typedef) and the SAME positive control (`int`) in nine HOMES.
package hpk129;
  typedef enum int { HA = 2, HB = 4 } hEnum129_e;
  typedef byte     hByte129_t;
  // package variable home
  hEnum129_e hPkgEnum129 [3];
  hByte129_t hPkgTdByte129 [5];
  int        hPkgInt129 [7];
  byte       hPkgByte129 [9];
  function automatic int hPkgFn129();
    hEnum129_e  fnEnum129 [11];
    hByte129_t  fnTdByte129 [13];
    int         fnInt129 [15];
    shortint    fnShort129[17];
    hPkgFn129 = 0;
  endfunction
  task automatic hPkgTk129;
    hEnum129_e  tkEnum129 [19];
    int         tkInt129  [21];
    tkInt129[0] = 0;
  endtask
endpackage

import hpk129::*;

class hcls129;
  // class property home
  hEnum129_e propEnum129 [23];
  hpk129::hByte129_t propTdByte129 [25];
  int        propInt129 [27];
  longint    propLong129 [29];
  task automatic inTask129();
    hEnum129_e  itEnum129 [31];
    int         itInt129  [33];
    begin : blk129
      hEnum129_e  blkEnum129 [35];
      int         blkInt129  [37];
      blkInt129[0] = 0;
    end
    itInt129[0] = 0;
  endtask
  extern function int oob129(hEnum129_e formalEnum129 [2],
                             int formalInt129 [4]);
endclass

function int hcls129::oob129(hEnum129_e formalEnum129 [2],
                             int formalInt129 [4]);
  hEnum129_e oobEnum129 [39];
  int        oobInt129  [41];
  oobInt129[0] = 0;
  oob129 = 0;
endfunction

module hmod129;
  import hpk129::*;
  // module variable home
  hEnum129_e modEnum129 [43];
  hByte129_t modTdByte129 [45];
  int        modInt129 [47];
  integer    modIntg129 [49];
  task automatic modTk129();
    hEnum129_e  mtEnum129 [51];
    int         mtInt129  [53];
    mtInt129[0] = 0;
  endtask
  initial begin : imblk129
    hEnum129_e  imEnum129 [55];
    int         imInt129  [57];
    imInt129[0] = 0;
  end
endmodule
