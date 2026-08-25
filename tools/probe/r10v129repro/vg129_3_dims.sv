// r10v129 verifier grid 3 - named element faces across FIVE dimension kinds
// (fixed 1-D, fixed 2-D, dynamic, queue, associative), plus the `int` positive
// control for each kind.
package dpk129;
  typedef enum int { DA = 6, DB = 8 } dEnum129_e;
  typedef int  dInt129_t;
  typedef struct packed signed { logic [3:0] p; logic [3:0] q; } dSps129_t;
endpackage

class dcls129;
  int seed129;
endclass

import dpk129::*;

module dmod129;
  task automatic tDims129();
    // fixed 1-D
    dEnum129_e  f1Enum129 [2];
    dInt129_t   f1Td129   [3];
    dSps129_t   f1Sps129  [4];
    dcls129     f1Cls129  [5];
    int         f1Int129  [6];
    byte        f1Byte129 [7];
    // fixed 2-D
    dEnum129_e  f2Enum129 [8][9];
    dInt129_t   f2Td129   [10][11];
    int         f2Int129  [12][13];
    // dynamic
    dEnum129_e  dyEnum129 [];
    dInt129_t   dyTd129   [];
    dSps129_t   dySps129  [];
    int         dyInt129  [];
    shortint    dyShort129[];
    // queue
    dEnum129_e  qEnum129  [$];
    dInt129_t   qTd129    [$];
    dcls129     qCls129   [$];
    int         qInt129   [$];
    longint     qLong129  [$];
    // associative (string / int / class / typedef keys)
    dEnum129_e  asEnumS129 [string];
    dEnum129_e  asEnumI129 [int];
    dInt129_t   asTd129    [string];
    dSps129_t   asSps129   [dInt129_t];
    dcls129     asCls129   [int];
    int         asInt129   [string];
    integer     asIntg129  [int];
    byte        asByte129  [dcls129];
    f1Int129[0] = 0;
  endtask
endmodule

class dcls2_129;
  dEnum129_e  cpEnum129 [$];
  dEnum129_e  cpEnumA129 [string];
  dInt129_t   cpTd129   [];
  int         cpInt129  [$];
  int         cpIntA129 [string];
  function automatic int fDims129();
    dEnum129_e  ffEnum129 [$];
    dEnum129_e  ffEnumA129[int];
    int         ffInt129  [$];
    int         ffIntA129 [int];
    fDims129 = 0;
  endfunction
endclass
