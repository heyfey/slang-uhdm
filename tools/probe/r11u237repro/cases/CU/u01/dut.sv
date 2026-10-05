// § clsTdUnionBuilt237
// pass 235's rs/r05: a class-scope packed union with an enum member
package p;
class pol;
  typedef enum {NEVER, STARTED, FINISHED} rs_e;
  typedef union packed {
     rs_e state;
     int raw;
  } su_t;
  su_t m_one;
endclass
endpackage
module top;
endmodule
