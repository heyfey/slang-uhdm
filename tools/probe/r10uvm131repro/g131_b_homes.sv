// r10uvm131 arm B — the same fork shapes in five HOMES:
// class task, module always, module initial, free package task, program.
package Pk8;
  task automatic pkg_spin(output int r);
    fork : pkgNamed
      r = 21;
    join_none
    fork
      r = 22;
    join_any
    lbl_pre_pkg : fork
      r = 23;
    join
  endtask
  class Cls5;
    int fld;
    task run_it();
      fork : clsNamed
        fld = 31;
      join_any
      fork
        fld = 32;
      join
      pre_cls : fork
        fld = 33;
      join_none
    endtask
    function void fn_it();
      fork : clsFnNamed
        fld = 34;
      join_none
    endfunction
  endclass
endpackage

module ArmBHomes(input logic clk);
  import Pk8::*;
  int m1, m2;
  always @(posedge clk) begin
    fork : alwNamed
      m1 = 41;
    join_none
    fork
      m2 = 42;
    join_any
  end
  initial begin
    fork : iniNamed
      m1 = 51;
    join
    pre_ini : fork
      m2 = 52;
    join_any
  end
endmodule

program ArmBProg;
  int p9;
  initial begin
    fork : prgNamed
      p9 = 61;
    join_none
    fork
      p9 = 62;
    join
  end
endprogram
