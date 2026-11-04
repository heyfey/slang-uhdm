// § cloneMembTdOwnCopy285
// an extern task with a block local, called from a task in the importer
package a; typedef bit [7:0] w_t; typedef struct { w_t lo; int n; } s_t;
  class C; int k; extern task t(); endclass
  task C::t(); begin s_t r; r.lo = 1; k = int'(r.lo); end endtask endpackage
package b; import a::*; task automatic g(output int o); C c; c = new(); c.t(); o = c.k; endtask endpackage
module top(output int o); import b::*; int r; initial g(r); assign o = r; endmodule
