// § classEnumViaHandleIsPath401
module top ();
  class cls;
    typedef enum {A, B} e_t;
  endclass
  int x;
  initial x = cls::B;
endmodule
