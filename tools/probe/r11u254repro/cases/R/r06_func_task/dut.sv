// § procReplCountOwner254 (a replication count inside a module function and task)
package pk;
  parameter int N = 3;
endpackage
module top;
  import pk::*;
  function automatic logic [5:0] f(); return {N{2'b10}}; endfunction
  task automatic t(output logic [5:0] o); o = {N{2'b01}}; endtask
  logic [5:0] q;
  always_comb q = f();
endmodule
