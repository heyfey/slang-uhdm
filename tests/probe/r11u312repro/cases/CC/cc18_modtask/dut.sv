// § clsLvTrailConcatTarget312
class holder; int idx[4]; endclass
module top; holder h; int i; int r; task t(); {h.idx[i + 1], r} = 2; endtask initial t(); endmodule
