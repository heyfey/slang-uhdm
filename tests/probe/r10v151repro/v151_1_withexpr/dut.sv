// r10v151 (VERIFIER) arm 1 — WHAT THE `with` CLAUSE READS, and the FULL
// array-method face list the brief names, each with and without `()` and with
// and without a clause.  Deliberately NOT self-confirming: the names,
// numbers, letters and orders all vary.  MEASUREMENT ONLY.
// LHS is always golden (Surelog), RHS always ours.
package Wpk1;
  class Rec1;
    int    ofs;
    int    key;
    string tag;
    function int wgt(); return ofs * 2; endfunction
  endclass
  class Body1;
    Rec1 recs[$];
    int  nums[$];
    int  THR;
    task go1;
      int z;
      // ---- with-clause CONTENTS ----
      nums.sort()  with ( item );                    // bare item
      nums.sort()  with ( item.index );              // item.index
      recs.sort()  with ( item.ofs );                // member
      recs.sort()  with ( item.wgt() );              // a CALL inside with
      nums.find()  with ( item > THR );              // reads an outer member
      nums.find()  with ( item + item.index * 3 );   // compound
      recs.find()  with ( item.tag == "zz" );        // string compare
      nums.sort()  with ( 1 );                       // constant clause
      nums.find( uu ) with ( uu != 0 );              // NAMED iterator
      // ---- the whole face list, with a clause ----
      nums.rsort()            with ( item );
      nums.find_index()       with ( item < 9 );
      nums.find_first()       with ( item < 9 );
      nums.find_last()        with ( item < 9 );
      nums.find_first_index() with ( item < 9 );
      nums.find_last_index()  with ( item < 9 );
      nums.unique()           with ( item );
      nums.unique_index()     with ( item );
      nums.sum()              with ( item );
      nums.product()          with ( item );
      nums.min()              with ( item );
      nums.max()              with ( item );
      // ---- the whole face list, NO clause, WITH parens ----
      nums.sort();  nums.rsort();  nums.reverse();  nums.shuffle();
      nums.unique();  nums.unique_index();
      nums.sum();  nums.product();  nums.min();  nums.max();
      // ---- NO clause, NO parens ----
      nums.sort;
      nums.rsort;
      nums.reverse;
      nums.shuffle;
      nums.unique;
      nums.unique_index;
      // ---- PARENS-LESS with a clause ----
      nums.sort   with ( item );
      nums.rsort  with ( item );
      z = 0;
    endtask
  endclass
endpackage
