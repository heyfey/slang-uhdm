// r10v129 verifier grid 1 - IMPORTED / $unit / PACKAGE-QUALIFIED named element
// types on declarator arrays.  LHS is always golden (Surelog).
// Sizes are all distinct and the order is not the emitter's dispatch order.
package vpk129;
  typedef enum int              { PIA = 3,  PIB = 5  } pEnumInt129_e;
  typedef enum bit [3:0]        { PBA = 1,  PBB = 2  } pEnumBit129_e;
  typedef enum logic signed [4:0] { PLA = 1, PLB = 2 } pEnumLgs129_e;
  typedef enum byte             { PYA = 7,  PYB = 9  } pEnumByte129_e;
  typedef int    pInt129_t;
  typedef string pStr129_t;
  typedef pInt129_t pChain129_t;
  typedef struct packed        { logic [7:0] hi; logic [7:0] lo; } pSpk129_t;
  typedef struct packed signed { logic [7:0] hi; logic [7:0] lo; } pSps129_t;
  typedef struct               { int wide; byte narrow;         } pSup129_t;
endpackage

typedef int unitInt129_t;
typedef enum shortint { UA = 11, UB = 13 } unitEnum129_e;
typedef byte unitByte129_t;

class vcls129;
  int dummy129;
endclass

module vmwild129;
  import vpk129::*;
  task automatic tWild129();
    pEnumInt129_e  wEnumInt129  [2];
    pEnumBit129_e  wEnumBit129  [3];
    pEnumLgs129_e  wEnumLgs129  [5];
    pEnumByte129_e wEnumByte129 [7];
    pInt129_t      wInt129      [11];
    pStr129_t      wStr129      [13];
    pChain129_t    wChain129    [17];
    pSpk129_t      wSpk129      [19];
    pSps129_t      wSps129      [23];
    pSup129_t      wSup129      [29];
    unitInt129_t   wUnitInt129  [31];
    unitEnum129_e  wUnitEnum129 [37];
    unitByte129_t  wUnitByte129 [41];
    vcls129        wCls129      [43];
    int            wPosInt129   [47];
    byte           wPosByte129  [53];
    longint        wPosLong129  [59];
    int unsigned   wNegInt129   [61];
    logic signed [3:0] wNegLgs129 [67];
    wPosInt129[0] = 1;
  endtask
endmodule

module vmexpl129;
  import vpk129::pEnumInt129_e;
  import vpk129::pInt129_t;
  import vpk129::pSps129_t;
  function automatic int fExpl129();
    pEnumInt129_e xEnumInt129 [4];
    pInt129_t     xInt129     [6];
    pSps129_t     xSps129     [8];
    int           xPosInt129  [10];
    shortint      xPosShort129[12];
    fExpl129 = 0;
  endfunction
endmodule

module vmqual129;
  task automatic tQual129();
    vpk129::pEnumInt129_e  qEnumInt129 [14];
    vpk129::pEnumByte129_e qEnumByte129[16];
    vpk129::pInt129_t      qInt129     [18];
    vpk129::pStr129_t      qStr129     [20];
    integer                qPosIntg129 [22];
    qPosIntg129[0] = 0;
  endtask
endmodule

// 1-3 instances of the SAME typedef, so a per-typedef answer and a
// per-declaration answer are distinguishable.
module vminst129;
  import vpk129::*;
  task automatic tInst129();
    pEnumInt129_e i1a129 [24];
    pEnumInt129_e i2a129 [26], i2b129 [28];
    pInt129_t     i3a129 [30], i3b129 [32], i3c129 [34];
    int           iPos1129[36], iPos2129[38];
    i1a129[0] = PIA;
  endtask
endmodule
