// § classScopeTdRetBuildsOwner206 (the owner sorts BEFORE the returning class; a task-called method; used from a module)
package p;
  class C #(type T = int); T v; endclass
  class A; typedef C #(byte) q_t; typedef enum {X0, X1} e_t; endclass
  class Z;
    function A::q_t f(); A::q_t r = new; return r; endfunction
    function A::e_t e(); return A::X1; endfunction
  endclass
endpackage
module r07;
  initial begin
    p::Z z = new;
    p::A::q_t h;
    h = z.f();
  end
endmodule
