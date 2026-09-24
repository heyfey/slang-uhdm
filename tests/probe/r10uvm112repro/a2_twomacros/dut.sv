// a2 — TWO macro lines, INTERLEAVED, five expansions.
// Separates "first expansion of this macro line" from "the PREVIOUS expansion".
package pk2;
  class BoxP #(type Q = int, string Nm = "?");
    int p1;
  endclass
  class BoxQ #(type Q = int, string Nm = "?");
    int q1;
  endclass
`define mk_p(X) typedef BoxP #(X,`"X`") pid;
`define mk_q(X) typedef BoxQ #(X,`"X`") qid;
  class d1_one;   `mk_p(d1_one)
  endclass
  class D2_two;   `mk_q(D2_two)
  endclass
  class d3_three; `mk_p(d3_three)
  endclass
  class D4_four;  `mk_q(D4_four)
  endclass
  class d5_five;  `mk_p(d5_five)
  endclass
endpackage
