// § dottedCallHpSpansInvocation294
// a built-in enum method through an interface instance
interface ifc; typedef enum {A, B, C} e_t; e_t e; endinterface
module top(output int o);
  ifc i0 ();
  always_comb o = i0.e.next();
endmodule
