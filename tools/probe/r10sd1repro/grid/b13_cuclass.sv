// class-scope typedef in a COMPILATION-UNIT class (no package at all).
class baseb; endclass
class regb #(type T = baseb, string TN = "<unknown>"); endclass
class ub extends baseb;
  typedef regb #(ub, "ub") tidb;
endclass
module topb; ub vb; initial vb = null; endmodule
