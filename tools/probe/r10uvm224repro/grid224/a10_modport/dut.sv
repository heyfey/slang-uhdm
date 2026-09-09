package p224m;
   typedef logic [1:0] tm224_t;
endpackage
interface if224m();
   import p224m::*;
   tm224_t m_td224;
   logic   m_lg224;
   int     m_i224;
   modport mp224 (input m_td224, output m_lg224);
endinterface
module sub224m(if224m.mp224 p);
endmodule
module top224m;
   if224m u_m224();
   sub224m u_s224(u_m224.mp224);
endmodule
