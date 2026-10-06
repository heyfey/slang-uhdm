// § procReplCountOwner254 (in a module function, a task with a named fork, a final block and an if condition)
package pk;
  parameter int N = 3;
  parameter int M = 2;
endpackage
module top import pk::*; (input logic [5:0] a, output logic [5:0] o);
  function automatic logic [5:0] fn(); return {N{2'b10}}; endfunction
  task automatic tk(output logic [5:0] x); fork : fk x = {N{2'b01}}; join endtask
  logic [5:0] t;
  initial begin : ib tk(t); if (a == {N{2'b11}}) t = fn(); end
  final begin : fb t = {N{2'b00}}; end
  assign o = t;
endmodule
