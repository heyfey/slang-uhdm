// v87 arm a1 — TYPE-PARAMETER DEFAULT KINDS, chains, typedef order/count.
package p87v;
  class base87; int x; endclass
  class other87; int y; endclass
  class par87 #(type T = base87); T h; endclass
  virtual class vbase87; pure virtual function void vf(); endclass

  typedef struct packed { logic [3:0] a; } st87;
  typedef enum logic [1:0] { E0, E1 } en87;

  class c1_87 #(type T = base87);
    typedef T t_t;
    T p;
  endclass

  class c2_87 #(type REQ = base87, type RSP = REQ);
    typedef REQ req_t;
    typedef RSP rsp_t;
    REQ p_req;
    RSP p_rsp;
  endclass

  class c3_87 #(type A = base87, type B = A, type C = B);
    typedef A a_t;
    typedef B b_t;
    typedef C c_t;
    A pa; B pb; C pc;
  endclass

  class c4_87 #(type A = base87, type B = other87);
    typedef A a_t;
    typedef B b_t;
    A pa; B pb;
  endclass

  class c5_87 #(type T = par87#(base87));
    typedef T t_t;
    T p;
  endclass

  class c7_87 #(type T = vbase87);
    typedef T t_t;
    T p;
  endclass

  class c8_87 #(type T = int, type U = st87, type V = en87);
    typedef T t_t; typedef U u_t; typedef V v_t;
    T pt; U pu; V pv;
  endclass

  class c9_87 #(type REQ = base87, type RSP = REQ);
    REQ p_req; RSP p_rsp;
  endclass

  class c10_87 #(type REQ = base87, type RSP = REQ);
    typedef REQ req_t;
    REQ p_req; RSP p_rsp;
  endclass

  class c11_87 #(type REQ = base87, type RSP = REQ);
    typedef RSP rsp_t;
    typedef REQ req_t;
    REQ p_req; RSP p_rsp;
  endclass

  class c12_87 #(type REQ = base87);
    typedef REQ a_t;
    typedef REQ b_t;
    REQ p;
  endclass
endpackage

module m87a1;
  import p87v::*;
  c2_87 #(base87) i2;
  initial begin end
endmodule
