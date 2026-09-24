// r10uvm151 arm A — METHODS x `with`-CLAUSE PRESENCE x PARENTHESES, in
// STATEMENT position, each with its RVALUE / ARGUMENT / CONDITION twin.
// MEASUREMENT ONLY.  LHS is always golden (Surelog), RHS always ours.
package pkA151;
  class itA151;
    int offset;
    int id;
  endclass
  class holdA151;
    itA151 qq[$];
    int    iq[$];
    task bodyA151;
      int r;
      // ---- STATEMENT position, `with` clause present (THE LAW) ----
      qq.sort() with ( item.offset );          // sort, parens, class queue
      iq.sort() with ( item );                 // sort, parens, int queue
      qq.sort with ( item.offset );            // sort, PARENS-LESS
      iq.rsort() with ( item );                // rsort
      iq.find() with ( item > 0 );             // find
      iq.find_index() with ( item > 0 );       // find_index
      iq.find_first() with ( item > 0 );       // find_first
      iq.find_last() with ( item > 0 );        // find_last
      iq.find_first_index() with ( item > 0 ); // find_first_index
      iq.find_last_index() with ( item > 0 );  // find_last_index
      iq.min() with ( item );                  // min
      iq.max() with ( item );                  // max
      iq.sum() with ( item );                  // sum
      iq.product() with ( item );              // product
      iq.unique() with ( item );               // unique + with
      iq.sort( x ) with ( x < 3 );             // WRITTEN iterator argument
      // ---- STATEMENT position, NO `with` clause (the fence) ----
      iq.sort();
      iq.sort;
      iq.rsort();
      iq.reverse();
      iq.shuffle();
      iq.unique_index();
      iq.sum();
      iq.min();
      iq.max();
      iq.product();
      iq.unique_index();  // twin of the keyword form, plain identifier
      // ---- the SAME calls in EXPRESSION positions (the other fence) ----
      r = iq.sum()  with ( item );             // rvalue, with
      r = iq.sum();                            // rvalue, no with
      r = iq.size();                           // rvalue, plain
      $display(iq.sum() with ( item ));        // argument, with
      $display(iq.sum());                      // argument, no with
      if (iq.sum() with ( item ) > 0) r = 1;   // condition, with
      if (iq.sum() > 0) r = 2;                 // condition, no with
      // CHAINED `.size()` DIRECTLY AFTER A `with` CLAUSE IS REFUSED BY
      // SURELOG'S PARSER (both `q.find() with (…).size()` and the
      // parenthesised `(q.find() with (…)).size()` raise PA0207), so the
      // chain is written as the two statements the grammar admits.
      iq.find() with ( item > 0 );             // statement, then
      r = iq.size();                           // the chained read
    endtask
  endclass
endpackage
