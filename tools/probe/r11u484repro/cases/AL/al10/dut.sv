// § cloneAliasCopyBareName484 (alias of a union in a task clone with two importers)
package u;
  typedef union packed { logic [7:0] a; logic [7:0] b; } op_t;
  typedef op_t op2_t;
  task automatic t(output logic [7:0] o);
    op2_t v;
    v.a = 8'd3;
    o = v.b;
  endtask
endpackage
package a;
  import u::*;
  task automatic g(output logic [7:0] o); t(o); endtask
endpackage
package b;
  import u::*;
  task automatic h(output logic [7:0] o); t(o); endtask
endpackage
module top;
  import a::*; import b::*;
  logic [7:0] x, y;
  initial begin g(x); h(y); end
endmodule
