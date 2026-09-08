// v1 — MUST-STAY-EMPTY: a package with NO data declarations at all.
// typedefs, parameters, a class, a function and a task must mint NOTHING
// into the importing interface's net list.
package pv1;
  typedef logic [3:0] nib_t;
  parameter int PV1 = 7;
  localparam int LV1 = 8;
  typedef enum {A1, B1} e1_t;
  class cv1; int m; endclass
  function automatic int fv1(input int a); return a + 1; endfunction
  task automatic tv1(input int a); endtask
endpackage

interface if_v1;
  import pv1::*;
  logic own_v1;
endinterface

module m_v1;
  import pv1::*;
  logic own_mv1;
endmodule
