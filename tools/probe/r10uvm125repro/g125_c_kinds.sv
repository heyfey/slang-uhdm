// r10uvm125 arm C — CALL KINDS carrying a converting output/inout actual:
// DPI import function, DPI import task, package free function, package task,
// class method (method_func_call / method_task_call), module task, and a
// system function with an output formal.
package pk125c;
  typedef bit [63:0] wide_t;
  import "DPI-C" context function int dpi_rd(input int p, output wide_t v);
  import "DPI-C" context task dpi_wr(input int p, output wide_t v);

  function automatic int pfun(input int p, output wide_t v);
    v = 64'd1; return p;
  endfunction
  task automatic ptask(input int p, output wide_t v);
    v = 64'd2;
  endtask

  class M125;
    int r;
    function automatic int mfun(input int p, output wide_t v);
      v = 64'd3; return p;
    endfunction
    task automatic mtask(input int p, output wide_t v);
      v = 64'd4;
    endtask
  endclass

  class C125;
    M125 m;
    bit [31:0] narr;
    int r;
    task automatic go();
      string s;
      m = new();
      r = dpi_rd(1, narr);        // DPI import function
      dpi_wr(2, narr);            // DPI import task
      r = pfun(3, narr);          // package free function
      ptask(4, narr);             // package task
      r = m.mfun(5, narr);        // method_func_call
      m.mtask(6, narr);           // method_task_call
      void'($value$plusargs("A=%d", narr));  // system function, output formal
      r = $sscanf(s, "%d", narr); // system function, output formal
    endtask
  endclass
endpackage
