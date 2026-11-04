// § cloneTfVarParentAtTf482 (downstream: cloned function locals in a combinational block, two importers)
package u;
  function automatic logic [7:0] f(input logic [7:0] n);
    logic [7:0] t;
    logic [7:0] w;
    t = n << 1;
    w = t | n;
    return w;
  endfunction
endpackage
package a;
  import u::*;
  function automatic logic [7:0] g(input logic [7:0] n); return f(n); endfunction
endpackage
package b;
  import u::*;
  function automatic logic [7:0] h(input logic [7:0] n); return f(n) ^ 8'h5a; endfunction
endpackage
module top(input logic [7:0] i, output logic [7:0] o, output logic [7:0] p);
  import a::*;
  import b::*;
  assign o = g(i);
  assign p = h(i);
endmodule
