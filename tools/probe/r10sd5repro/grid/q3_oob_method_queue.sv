// q3 — a queue local of an OUT-OF-BODY class method.  sd3's
// § retNameLocalInstIsHomeNotClass3 says out-of-body takes the home package.
package p3;
  typedef struct { int a; } s3_t;
  class c3;
    extern function int f3();
  endclass
  function int c3::f3();
    s3_t q3[$];
    q3.push_back('{a:2});
    return q3.size();
  endfunction
endpackage
module top3;
  p3::c3 h3;
  initial h3 = new();
endmodule
