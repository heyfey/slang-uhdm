// r10v189 arm N — NESTED assoc dims, QUEUE/DYNAMIC negatives, SCOPED index.
// One home package, one wildcard importer, one top module.
package HomeN189v;
  class KeyN189v;
    int fldN189v;
  endclass
  class OtherN189v;
    int oth2N189v;
  endclass
  typedef KeyN189v tdKeyN189v;

  class WorkN189v;
    extern function void oobN189v();
    extern task oobTaskN189v();
  endclass

  function void WorkN189v::oobN189v();
    bit nnA189v[KeyN189v][OtherN189v];      // both dims NAMED
    bit nkB189v[KeyN189v][string];          // named outer, keyword inner
    bit knC189v[string][KeyN189v];          // keyword outer, named inner
    bit scD189v[HomeN189v::KeyN189v];       // SCOPED name index
    int qE189v[$];                          // queue negative
    int dF189v[];                           // dynamic negative
    bit qgG189v[KeyN189v][$];               // assoc-of-queue: no array_var
    bit dgH189v[KeyN189v][];                // assoc-of-dynamic: no array_var
    int uI189v[4];                          // fixed unpacked negative
    bit twoJ189v[KeyN189v];                 // plain, instance 1
    bit twoK189v[KeyN189v];                 // plain, instance 2
    nnA189v[null][null] = 1'b1;
    nkB189v[null]["p"] = 1'b1;
    knC189v["p"][null] = 1'b1;
    scD189v[null] = 1'b1;
    qE189v.push_back(9);
    dF189v = new[3];
    uI189v[0] = 1;
    twoJ189v[null] = 1'b1;
    twoK189v[null] = 1'b0;
  endfunction

  task WorkN189v::oobTaskN189v();
    bit tskL189v[tdKeyN189v];
    bit tskM189v[KeyN189v][KeyN189v];
    tskL189v[null] = 1'b1;
    tskM189v[null][null] = 1'b1;
  endtask

  function void freeN189v();
    bit frN189v[KeyN189v][string];
    bit frO189v[KeyN189v];
    frN189v[null]["r"] = 1'b1;
    frO189v[null] = 1'b1;
  endfunction
endpackage

package UserN189v;
  import HomeN189v::*;
  function void useN189v();
    WorkN189v wN189v;
    wN189v = new();
    wN189v.oobN189v();
    freeN189v();
  endfunction
endpackage

module topN189v;
  import UserN189v::*;
  initial useN189v();
endmodule
