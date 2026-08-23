// r10vbuvm29 arm G (VERIFIER) — is the cast TARGET TYPESPEC NAME under a
// stream a NEW residue, or the pre-existing cast road's?  Every cell here is a
// cast over a NON-stream operand, so PRISTINE already emits the cast: whatever
// name it puts on the target typespec is the road's behaviour, not this
// patch's.
package vg29;
  typedef logic signed [15:0] sv_t;
  typedef bit [1:0][7:0] two_d;
  typedef union packed { bit [7:0] u8; } up;
  typedef enum bit [7:0] { G0 = 8'h1 } ge;
  class C;
    sv_t q2; two_d q3; up q1; ge q4;
    function void f();
      q2 = sv_t'(16'h1);
      q3 = two_d'(16'h2);
      q1 = up'(8'h3);
      q4 = ge'(8'h1);
    endfunction
  endclass
endpackage
