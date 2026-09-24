// CONTROL, r10sd1 cell b13's shape: cu class, cu target.  Golden FIRES here and
// must keep firing.
class baseb; endclass
class regb #(type T = baseb, string TN = "<unknown>"); endclass
class ub extends baseb;
  typedef regb #(ub, "ub") tidb;
endclass
module topb; ub vb; initial vb = null; endmodule
