// v87 arm a7 — isolate what a TYPEDEF-OF-A-TYPEDEF does to the group name.
package p87c;
  class b87; int x; endclass

  // control: single typedef of the last parameter
  class k1_87 #(type REQ = b87, type RSP = REQ);
    typedef RSP rsp_t;
    REQ p;
  endclass

  // the refuting shape: a typedef OF that typedef
  class k2_87 #(type REQ = b87, type RSP = REQ);
    typedef RSP rsp_t;
    typedef rsp_t rsp2_t;
    REQ p;
  endclass

  // an unrelated class typedef after the winner
  class k4_87 #(type REQ = b87, type RSP = REQ);
    typedef RSP rsp_t;
    typedef b87 other_t;
    REQ p;
  endclass

  // an unrelated NON-class typedef after the winner
  class k5_87 #(type REQ = b87, type RSP = REQ);
    typedef RSP rsp_t;
    typedef int i_t;
    REQ p;
  endclass

  // chain on the NON-winning parameter only
  class k6_87 #(type REQ = b87, type RSP = REQ);
    typedef REQ req_t;
    typedef req_t req2_t;
    typedef RSP rsp_t;
    REQ p;
  endclass

  // a queue typedef built on the winner
  class k7_87 #(type REQ = b87, type RSP = REQ);
    typedef RSP rsp_t;
    typedef rsp_t rsp_q_t[$];
    REQ p;
  endclass

  // two typedefs of the last parameter, plus a chain off the FIRST of them
  class k8_87 #(type REQ = b87, type RSP = REQ);
    typedef RSP x_t;
    typedef RSP y_t;
    typedef x_t x2_t;
    REQ p;
  endclass
endpackage

module m87a7;
  import p87c::*;
  k1_87 #(b87) i0;
  initial begin end
endmodule
