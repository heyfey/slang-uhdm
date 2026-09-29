// § tfArgScalarTdWriter223 — formals of a $unit-imported scalar typedef in an interface task, a module function, a class inside a module and a class inside an interface
package p;
  typedef int      FILE_T;
  typedef bit [3:0] NIB_T;
endpackage
import p::*;
interface bus_i;
  task automatic put(FILE_T f, NIB_T n); endtask
  class ic;
    function void g(FILE_T f); endfunction
  endclass
endinterface
module top(output int o);
  function automatic int mf(FILE_T f, NIB_T n); return f + n; endfunction
  class mc;
    function int h(NIB_T n, FILE_T f); return n + f; endfunction
  endclass
  bus_i u_b();
  assign o = mf(3, 4'd2);
endmodule
