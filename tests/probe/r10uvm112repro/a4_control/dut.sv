// a4 — CONTROL: two hand-written specializations at DIFFERENT locations.
// These must NOT collapse under any hypothesis.
package pk4;
  class BoxC #(type Q = int, string Nm = "?");
    int c1;
  endclass
  class f1_cat; int k1; endclass
  class F2_Dog; int k2; endclass
  class holder1; typedef BoxC #(f1_cat,"f1_cat") t1id;
  endclass
  class Holder2; typedef BoxC #(F2_Dog,"F2_Dog") t2id;
  endclass
endpackage
