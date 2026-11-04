// § clsPropSpecFullNameLazy470 (a module-local class property specialization)
module top;
  class res #(type T = int); T v; endclass
  class C; res#(shortint) pr; endclass
  C c;
endmodule
