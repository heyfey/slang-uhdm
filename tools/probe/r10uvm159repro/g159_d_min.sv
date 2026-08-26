// r10uvm159 GRID D — the law's shape with NO UVM: a package materialises a
// wildcard-imported package parameter and a CLASS METHOD folds a read of it as
// an OPERATION operand.  This is the arm that decides whether the stamp is
// keyed on the IMPORT MATERIALISATION alone or on something UVM supplies, and
// it is this pass's POSITIVE CONTROL in the wide boundary gate (it compiles
// stand-alone, with no include path).
package q159d_pkg;
  parameter int QD159T = 61;
  parameter     QD159U = 62;
  parameter bit [7:0] QD159B = 8'd63;
  parameter string    QD159S = "qd";
endpackage

package p159d_pkg;
  import q159d_pkg::*;
  class c159d;
    int    r159;
    string s159;
    function void d_op();
      r159 = QD159T + 1;
      r159 = QD159U + 1;
      r159 = QD159B + 1;
      s159 = {QD159S, "x"};
      if (r159 inside {QD159T, QD159U}) r159 = 0;
    endfunction
    function void d_plain();
      r159 = QD159T;
    endfunction
    function void d_qual();
      r159 = q159d_pkg::QD159T + 1;
    endfunction
  endclass
endpackage

module m159d;
  import p159d_pkg::*;
  c159d h159;
  initial begin
    h159 = new();
    h159.d_op();
  end
endmodule
