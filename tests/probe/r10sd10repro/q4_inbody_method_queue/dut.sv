// q4 — a queue local of an IN-BODY class method.  sd3's second rule: in-body
// takes nothing.
package p4;
  typedef struct { int a; } s4_t;
  class c4;
    function int f4();
      s4_t q4[$];
      q4.push_back('{a:3});
      return q4.size();
    endfunction
  endclass
endpackage
module top4;
  p4::c4 h4;
  initial h4 = new();
endmodule
