// r10vbuvm28 arm D — REACH: argument shapes where the patch's typespec pick
// (selChainRoot95 / a.type) could disagree with Surelog's `compileBits`.
package pd;
  typedef enum { D0, D1 } de_t;
  typedef enum bit [2:0] { X0 } dx_t;
  typedef struct packed { de_t c; bit [7:0] d; } dps_t;
  function automatic de_t retbare(); return D0; endfunction
  function automatic dx_t retbased(); return X0; endfunction
  function automatic dps_t retstruct(); dps_t z; return z; endfunction
endpackage

module gv28_d_reach;
  import pd::*;
  de_t  e1, e2;
  dx_t  x1;
  dps_t s1;
  de_t  earr [2];
  bit   b1;
  int   r [30];
  function automatic de_t lf(); return D0; endfunction
  function automatic int  li(); return 0;  endfunction
  initial begin
    r[0]  = $bits(retbare());          // CALL returning a base-less enum
    r[1]  = $bits(retbased());         // CALL returning a based enum
    r[2]  = $bits(retstruct());        // CALL returning a packed struct
    r[3]  = $bits(lf());               // local function, base-less enum
    r[4]  = $bits(li());               // local function, int
    r[5]  = $bits({e1, e2});           // CONCAT of two base-less enums
    r[6]  = $bits({e1, b1});           // CONCAT enum + bit
    r[7]  = $bits({2{e1}});            // REPLICATION
    r[8]  = $bits(de_t'(0));           // CAST to a base-less enum
    r[9]  = $bits(int'(e1));           // CAST to int
    r[10] = $bits(e1 == D0);           // comparison (golden keeps)
    r[11] = $bits(earr[0]);            // select on an array of base-less enum
    r[12] = $bits(earr);               // the whole array
    r[13] = $bits(s1.c);               // member that IS a base-less enum
    r[14] = $bits(s1.d);               // member that is not
    r[15] = $clog2($bits(e1) + 1);     // nested
    r[16] = $size(earr);               // $size must not move
    r[17] = $high(earr, 1);            // $high must not move
    r[18] = $bits(de_t);               // TYPE name
    r[19] = $bits(pd::de_t);           // SCOPED type name
    r[20] = $bits(dps_t);              // struct TYPE name
    case ($bits(de_t))
      0: r[21] = 1;
      default: r[21] = 2;
    endcase
    r[22] = {$bits(de_t), 1'b0};       // inside a concat
    r[23] = $bits(e1) + $bits(x1);     // arithmetic over both
  end
endmodule
