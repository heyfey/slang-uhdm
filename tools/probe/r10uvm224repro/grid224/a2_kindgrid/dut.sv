package p224b;
   class Cb224;
      int x;
   endclass
   typedef struct packed { int a; } sp224_t;
   typedef struct { int a; } su224_t;
   typedef enum { E0, E1 } en224_t;
   typedef int ti224_t;
endpackage

class CTop224;
   int y;
endclass

interface if224b();
   import p224b::*;
   Cb224      w_cls224;
   Cb224      w_clsdyn224 [];
   p224b::Cb224 q_cls224;
   CTop224    u_cls224;
   sp224_t    sp224;
   su224_t    su224;
   en224_t    en224;
   ti224_t    ti224;
   ti224_t    tidyn224 [];
   logic [3:0] pk224;
   logic [3:0] pkdyn224 [];
   int        aq224 [$];
   int        as224 [string];
endinterface

module m224b();
   import p224b::*;
   Cb224      w_cls224;
   Cb224      w_clsdyn224 [];
   sp224_t    sp224;
   int        m_dyn224 [];
endmodule

module top224b;
   if224b u_if();
endmodule
