// r10v151 (VERIFIER) arm 6 — NAME COLLISIONS AND CASE.  A receiver named after
// the method, a receiver that shares its name with a subroutine, a local named
// `item`, mixed case, and the same law cell repeated on receivers whose names
// sort in a different order than they are written.  MEASUREMENT ONLY.
// LHS is always golden (Surelog), RHS always ours.
package Spk6;
  function automatic int zebra6(int q6); return q6 + 1; endfunction
  class Trap6;
    int sort[$];          // a QUEUE named after a method
    int reverse[$];
    int zebra6[$];        // shares its name with the package function
    int Sum[$];           // differs from `sum` only in case
    int item;             // a member named `item`
    task hit6;
      int find;           // a LOCAL named after a method
      int item;           // a LOCAL named `item`
      int alpha6[$];
      find = 0;
      item = 0;
      sort.sort()      with ( item );      // receiver named `sort`
      reverse.reverse();
      reverse.rsort()  with ( item );
      zebra6.sort()    with ( item );      // receiver shadows a function name
      Sum.sum();
      Sum.sort()       with ( item );
      alpha6.sort()    with ( item.index );
      sort.unique();
      zebra6.unique();
      // written in this order, sorted in another
      alpha6.find_first() with ( item > 0 );
      zebra6.find_last()  with ( item > 0 );
      Sum.find_index()    with ( item > 0 );
      find = zebra66(1);
    endtask
    function int zebra66(int k6); return k6; endfunction
  endclass
endpackage
