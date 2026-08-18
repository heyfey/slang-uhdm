// v97_c6 — every typedef SHAPE inside a parameterized class with two live
// specializations: forward typedef, typedef of a specialization, of another
// class, of a NESTED class, of an INTERFACE class, of builtin/struct/enum/
// union/typedef-of-typedef and a parameter-dependent one.
typedef class fwd97c6;
package p97c6;
  class oth97c6;
    int o;
  endclass
  class gen97c6 #(type G = int);
    G g;
  endclass
  class nesthome97c6;
    class nest97c6;
      int n;
    endclass
  endclass
  class kinds97c6 #(type T = int);
    typedef bit [7:0]                     td_vec97c6;
    typedef int                           td_int97c6;
    typedef struct packed { bit a; bit b; } td_st97c6;
    typedef enum { E0_97C6, E1_97C6 }     td_en97c6;
    typedef td_int97c6                    td_td97c6;
    typedef T                             td_tp97c6;
    typedef gen97c6 #(T)                  td_spec97c6;
    typedef gen97c6 #(int)                td_speci97c6;
    typedef oth97c6                       td_oth97c6;
    typedef nesthome97c6::nest97c6        td_nest97c6;
    typedef kinds97c6 #(T)                this_type97c6;
    td_vec97c6   a_vec;
    td_int97c6   a_int;
    td_st97c6    a_st;
    td_en97c6    a_en;
    td_td97c6    a_td;
    td_tp97c6    a_tp;
    td_spec97c6  a_spec;
    td_speci97c6 a_speci;
    td_oth97c6   a_oth;
    td_nest97c6  a_nest;
    this_type97c6 a_self;
  endclass
  class ki97c6 extends kinds97c6 #(int);
    function void f(this_type97c6 p); a_self = p; endfunction
  endclass
  class kb97c6 extends kinds97c6 #(byte);
    function void f(this_type97c6 p); a_self = p; endfunction
  endclass
endpackage
module top97c6;
endmodule
