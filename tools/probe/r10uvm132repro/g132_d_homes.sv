// r10uvm132 arm D — HOMES.  The same pasted-macro receiver inside an IN-BODY
// class method, an OUT-OF-BODY class method, a free PACKAGE function, a free
// PACKAGE task, a MODULE task, an `initial` block and an `always` block.
`include "g132_defs.svh"

package pkg_d132;
  string qpkgfn132[$];
  string qpkgtk132[$];
  function void f_d132();
    `G132_QDA(QUEUE, qpkgfn132)
  endfunction
  task t_d132();
    `G132_QDA(QUEUE, qpkgtk132)
  endtask
endpackage

module top_d132;
  string qmodtask132[$];
  string qinit132[$];
  string qalways132[$];

  class cls_d132;
    string qin132[$];
    string qout132[$];
    function void in_d132();
      `G132_QDA(QUEUE, qin132)
    endfunction
    extern function void out_d132();
  endclass

  function void cls_d132::out_d132();
    `G132_QDA(QUEUE, qout132)
  endfunction

  task tk_d132();
    `G132_QDA(QUEUE, qmodtask132)
  endtask

  cls_d132 h_d132;
  initial begin
    `G132_QDA(QUEUE, qinit132)
  end
  always @(*) begin
    `G132_QDA(QUEUE, qalways132)
  end
endmodule
