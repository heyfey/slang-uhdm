// r10uvm128 arm D — the HOME of the two-buffer receiver: an in-body class
// method, an OUT-OF-BODY method, a nested `begin` inside a class task, a free
// function in the package, a module task, and a module `initial` block.  The
// corpus head sits in a nested `begin` of an in-body class function; if any
// other home behaved differently the law would be home-conditional, and it is
// not.
`include "g128_defs.svh"
package pkg_d128;
class cls_d128;
  string que128[$];
  int rc128;
  cls_d128 ob128;
  function void f_inbody();
    `D128_CELL(que128)
  endfunction
  extern function void f_outofbody();
  task t_nested();
    begin
      begin
        `D128_CELL(que128)
      end
    end
  endtask
endclass
function void cls_d128::f_outofbody();
  `D128_CELL(que128)
endfunction
class holder_d128;
  string que128[$];
  int rc128;
  holder_d128 ob128;
endclass
function automatic void free_d128(holder_d128 h);
  if (h.que128.size() != 0) h.rc128 = 1;
endfunction
endpackage
module top_d128;
  import pkg_d128::*;
  cls_d128 c;
  initial c = new();
endmodule
