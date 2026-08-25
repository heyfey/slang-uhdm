// v149c arm -- THE UNION HALF of the hook: a TAGGED union carrying a queue
// member, and an unpacked union next to it.
package Tau9_pkg;
  typedef union tagged {
    void   TagNone;
    string TagQ[$];
    int    TagInt;
  } tagged_q_u;

  typedef struct {
    tagged_q_u holderTagged;
    string     holderQ[$];
  } tagged_holder_t;

  tagged_holder_t theTagged;
endpackage

module tagged_top;
  import Tau9_pkg::*;
  tagged_holder_t t3;
  initial t3.holderQ.push_back("z");
endmodule
