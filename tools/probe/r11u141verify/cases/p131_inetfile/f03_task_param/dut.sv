// § implicitNetMintNoFile131
// case f03: a task-scope parameter used in the task body
module top(output logic [3:0] y);
  task automatic t(output logic [3:0] o);
    parameter int P = 3;
    o = P;
  endtask
  initial t(y);
endmodule
