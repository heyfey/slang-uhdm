// r10uvm115 / g115_b.sv — THE CONTROL ARM.  A USER class NAMED `process`
// (and a user `semaphore`), declared in the same package, so the written token
// resolves to a REAL design class on both sides.  If golden binds it properly
// here, the law MUST NOT fire when the name resolves to a user class.
package q115;

  class process;
    int x;
    static function process self(); return null; endfunction
  endclass

  class semaphore;
    int keys;
  endclass

  function void qfn115();
    process p;          // resolves to q115::process
    semaphore s;        // resolves to q115::semaphore
    p = process::self();
  endfunction

  class qc115;
    function void qmeth();
      process mp;
    endfunction
  endclass

endpackage

// a SECOND control: a package with a TYPEDEF named `process`
package r115;
  typedef int process;
  function void rfn115();
    process p;          // an int
    p = 3;
  endfunction
endpackage
