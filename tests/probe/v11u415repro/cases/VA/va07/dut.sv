// § labeledCallStmtLabelDropped415
module top(input logic [7:0] a, output logic [7:0] o);
  function automatic logic [7:0] f(input logic [7:0] x); return x + 1; endfunction
  task t(input logic [7:0] x); o = x; endtask
  initial begin
    lt: t(f(a));
  end
endmodule
