// r10uvm214 grid arm B — THE IN-BODY CONTROL.  The same package, the same
// parameters and the same reads, with the methods DEFINED INSIDE the class
// body.  An in-body method is never listed in the package's Task_funcs, so the
// def-listing clone this pass's law lives in does not exist here and no cell of
// it may move.
package pb214p;

  parameter int qa214 = 5;
  parameter qb214 = qa214;
  parameter qc214 = qa214 + 1;

  function automatic int qsink214(int a, int b);
    return a + b;
  endfunction

  class QB214;
    function int rd_arg214();
      return qsink214(qa214, qb214);
    endfunction
    function int rd_asgn214();
      int r;
      r = qb214;
      r = qc214;
      return r;
    endfunction
    function int rd_ret214();
      return qb214;
    endfunction
  endclass

endpackage

module topb214;
  pb214p::QB214 c = new();
  int x;
  initial x = c.rd_arg214();
endmodule
