// § classEnumViaHandleIsPath401
module top ();
  class cls;
    typedef enum {A, B} e_t;
  endclass
  cls h;
  int x;
  initial begin
    h = new;
    x = h.B;
  end
endmodule
