// r10v129 verifier grid 4 - the GUARD-INTERACTION faces: type parameters
// (ref_var path), class-scope typedef kinds, nested/fork/for blocks, const,
// static vs automatic, mixed dimensions of a NAMED element type.
package bpk129;
  typedef enum int { BA = 2, BB = 3 } bEnum129_e;
  typedef logic signed [3:0] bLgs129_t;
  typedef int bInt129_t;
endpackage
import bpk129::*;

class bparam129 #(type T129 = int, int W129 = 4);
  T129 tpProp129 [3];
  function automatic int fTp129();
    T129 tpLoc129   [5];
    T129 tpQue129   [$];
    T129 tpDyn129   [];
    T129 tpAsc129   [string];
    int  tpPos129   [7];
    fTp129 = 0;
  endfunction
endclass

class bhold129;
  typedef enum byte { CA = 4, CB = 6 } cEnum129_e;
  typedef bInt129_t cChain129_t;
  function automatic int fNested129();
    cEnum129_e   nsEnum129 [9];
    cChain129_t  nsChain129 [11];
    bhold129::cEnum129_e nsQual129 [13];
    bLgs129_t    nsLgs129 [15];
    int          nsPos129 [17];
    begin : outer129
      cEnum129_e  o1Enum129 [19];
      int         o1Int129  [21];
      begin : inner129
        cEnum129_e i1Enum129 [23];
        byte       i1Byte129 [25];
        i1Byte129[0] = 0;
      end
      o1Int129[0] = 0;
    end
    for (int k129 = 0; k129 < 2; k129++) begin : loop129
      cEnum129_e lpEnum129 [27];
      shortint   lpShort129[29];
      lpShort129[0] = 0;
    end
    nsPos129[0] = 0;
    fNested129 = 0;
  endfunction
  task automatic tFork129();
    fork
      begin : fk129
        cEnum129_e fkEnum129 [31];
        longint    fkLong129 [33];
        fkLong129[0] = 0;
      end
    join
  endtask
endclass

module bmod129;
  bparam129 #(bEnum129_e, 8) inst129;
  task automatic tMisc129();
    const int      cInt129 [35] = '{default:0};
    static bEnum129_e stEnum129 [37];
    static int     stInt129 [39];
    bEnum129_e     mxEnum129 [41][];
    int            mxInt129  [43][];
    bLgs129_t      tdLgs129  [45];
    bEnum129_e     bigEnum129 [47][49];
    stInt129[0] = 0;
  endtask
endmodule
