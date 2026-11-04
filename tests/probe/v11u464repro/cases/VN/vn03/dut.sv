// § clsNestedUnsizedDims464 (a packed struct typedef element)
typedef struct packed { logic [3:0] a; logic b; } s_t;
class C;
  s_t d[][];
endclass
module top;
  initial begin C c; c = new; end
endmodule
