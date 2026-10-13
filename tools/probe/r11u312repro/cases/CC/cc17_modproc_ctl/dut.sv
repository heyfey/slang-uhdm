// § clsLvTrailConcatTarget312
class holder; int idx[4]; endclass
module top; holder h; int i; int r; always_comb {h.idx[i + 1], r} = 2; endmodule
