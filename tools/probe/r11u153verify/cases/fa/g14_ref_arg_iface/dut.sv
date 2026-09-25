// § tfArgTypedefLastWriter146
typedef enum logic [1:0] {A, B, C} e_t;
interface ifc;
  function automatic void f(ref e_t x); x = B; endfunction
endinterface
module top(output int o);
  ifc i();
  assign o = 0;
endmodule
