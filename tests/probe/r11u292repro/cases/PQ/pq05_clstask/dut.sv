// § pkgVarLvalueScopeSep292
package q;
  int qi = 3;
  logic [7:0] qv;
endpackage
package p;
  class c;
    task t();
      q::qi = 3;
      q::qv[1] = 1'b1;
      q::qv[3:2] = 2'b1;
    endtask
  endclass
endpackage
module top; p::c o = new(); endmodule
