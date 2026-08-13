// r10svs14 VERIFIER ARM — the header-port DATA TYPES the pass predicted but did
// not measure (its own §6.9), plus three kinds it never named at all.
//
// Every interface here carries a modport and is handed WHOLE (a bare, dot-free
// connection) to a sibling module's interface port, which is what mints the col-0
// tail duplicate.  The question each cell asks is the ONLY question the law
// turns on: does golden's DUP list the header port's object, and do we?
//
// Read with dupread.py; the verdict column is (PRIS vs GOLDEN, SHIP vs GOLDEN).

typedef enum logic [1:0] { E0, E1 } e_t;
typedef struct packed { logic a; logic b; } sp_t;
typedef bit [3:0] nib_t;

interface k1_if(input real r);            // real       — §6.9 "predicted, not measured"
   logic d;
   modport mp(input r, d);
endinterface

interface k2_if(input time t);            // time       — §6.9 "predicted, not measured"
   logic d;
   modport mp(input t, d);
endinterface

interface k3_if(input var logic v);       // var logic  — §6.9 "predicted, not measured"
   logic d;
   modport mp(input v, d);
endinterface

interface k4_if(input byte b);            // byte       — never named
   logic d;
   modport mp(input b, d);
endinterface

interface k5_if(input e_t e);             // enum typedef — never named
   logic d;
   modport mp(input e, d);
endinterface

interface k6_if(input sp_t sp);           // packed struct typedef — never named
   logic d;
   modport mp(input sp, d);
endinterface

interface k7_if(input nib_t n);           // 2-state typedef — never named
   logic d;
   modport mp(input n, d);
endinterface

interface k8_if(input logic signed [3:0] s);   // 4-state ranged — must stay a net
   logic d;
   modport mp(input s, d);
endinterface

interface k9_if(output bit o, input logic i);  // MIXED direction, bit + logic
   logic d;
   modport mp(output o, input i, d);
endinterface

module rcv1(k1_if.mp p); endmodule
module rcv2(k2_if.mp p); endmodule
module rcv3(k3_if.mp p); endmodule
module rcv4(k4_if.mp p); endmodule
module rcv5(k5_if.mp p); endmodule
module rcv6(k6_if.mp p); endmodule
module rcv7(k7_if.mp p); endmodule
module rcv8(k8_if.mp p); endmodule
module rcv9(k9_if.mp p); endmodule

module top;
   real  rr;
   time  tt;
   logic vv, ii;
   byte  bb;
   e_t   ee;
   sp_t  ss;
   nib_t nn;
   logic signed [3:0] gg;
   bit   oo;

   k1_if k1(rr);
   k2_if k2(tt);
   k3_if k3(vv);
   k4_if k4(bb);
   k5_if k5(ee);
   k6_if k6(ss);
   k7_if k7(nn);
   k8_if k8(gg);
   k9_if k9(oo, ii);

   rcv1 r1(k1);   // BARE, dot-free -> mints the col-0 tail dup
   rcv2 r2(k2);
   rcv3 r3(k3);
   rcv4 r4(k4);
   rcv5 r5(k5);
   rcv6 r6(k6);
   rcv7 r7(k7);
   rcv8 r8(k8);
   rcv9 r9(k9);
endmodule
