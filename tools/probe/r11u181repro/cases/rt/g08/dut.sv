// § rootPathFullNameByChain181 § rootNetPathOwnNames181 — a $root read inside a module task
module top; logic [3:0] v; sub u(); endmodule
module sub; logic [3:0] w; task t(); w = $root.top.v; endtask initial t(); endmodule
